import { Pool } from "pg";
import { ethers } from "ethers";
import * as dotenv from "dotenv";
import { Kafka, Producer } from "kafkajs";

dotenv.config();

const aggregatorV3InterfaceABI = [
  {
    inputs: [],
    name: "decimals",
    outputs: [{ internalType: "uint8", name: "", type: "uint8" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "description",
    outputs: [{ internalType: "string", name: "", type: "string" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [{ internalType: "uint80", name: "_roundId", type: "uint80" }],
    name: "getRoundData",
    outputs: [
      { internalType: "uint80", name: "roundId", type: "uint80" },
      { internalType: "int256", name: "answer", type: "int256" },
      { internalType: "uint256", name: "startedAt", type: "uint256" },
      { internalType: "uint256", name: "updatedAt", type: "uint256" },
      { internalType: "uint80", name: "answeredInRound", type: "uint80" },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "latestRoundData",
    outputs: [
      { internalType: "uint80", name: "roundId", type: "uint80" },
      { internalType: "int256", name: "answer", type: "int256" },
      { internalType: "uint256", name: "startedAt", type: "uint256" },
      { internalType: "uint256", name: "updatedAt", type: "uint256" },
      { internalType: "uint80", name: "answeredInRound", type: "uint80" },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "version",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
];
// const provider = new ethers.JsonRpcProvider(`https://arb-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);
const provider = new ethers.JsonRpcProvider(`https://polygon-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);
// const provider = new ethers.JsonRpcProvider("https://rpc.ankr.com/eth_sepolia");

const priceFeeds = [
  {
    network: "polygon",
    address: "0x0f6914d8e7e1214CDb3A4C6fbf729b75C69DF608", // PAXG / USD on Polygon
    symbol: "PAXG/USD",
    baseCurrency: "PAXG",
    quoteCurrency: "USD",
  },
  {
    network: "polygon",
    address: "0x0C466540B2ee1a31b441671eac0ca886e051E410", // XAU / USD on Polygon
    symbol: "XAU/USD",
    baseCurrency: "XAU",
    quoteCurrency: "USD",
  },
  {
    network: "polygon",
    address: "0x461c7B8D370a240DdB46B402748381C3210136b3", // XAG / USD on Polygon
    symbol: "XAG/USD",
    baseCurrency: "XAG",
    quoteCurrency: "USD",
  },
  {
    network: "polygon",
    address: "0x76631863c2ae7367aF8f37Cd10d251DA7f1DE186", // XPT / USD on Polygon (Platinum))
    symbol: "XPT/USD",
    baseCurrency: "XPT",
    quoteCurrency: "USD",
  },
  {
    network: "polygon",
    address: "0xF9680D99D6C9589e2a93a78A04A279e509205945", // ETH / USD on Polygon
    symbol: "ETH/USD",
    baseCurrency: "ETH",
    quoteCurrency: "USD",
  },
  {
    network: "polygon",
    address: "0xc907E116054Ad103354f2D350FD2514433D57F6f", // BTC / USD on Polygon
    symbol: "BTC/USD",
    baseCurrency: "BTC",
    quoteCurrency: "USD",
  },
];

const kafka = new Kafka({
  clientId: "chainlink-pricefeed",
  brokers: ["127.0.0.1:9092"], // Replace with your Kafka broker addresses
});
const producer: Producer = kafka.producer();

// // PostgreSQL (TimescaleDB) connection setup
const pool = new Pool({
  connectionString: process.env.TIMESCALE_DB_CONNECTION_URI,
});

async function getPrice(feedAddress: string): Promise<{ timestamp: number; price: number }> {
  const priceFeed = new ethers.Contract(feedAddress, aggregatorV3InterfaceABI, provider);
  const roundData = await priceFeed.latestRoundData();
  const decimals = await priceFeed.decimals();
  // console.log("roundData:", roundData);
  const [roundId, answer, startedAt, updatedAt, answeredInRound] = roundData;

  const price = Number(answer) / Math.pow(10, Number(decimals));
  return { timestamp: Number(updatedAt), price };
}

async function fetchPricesPipeline() {
  // fetch prices -> insert price into DB -> publish via Kafka
  try {
    for (const pricefeed of priceFeeds) {
      const { timestamp, price } = await getPrice(pricefeed.address);
      const symbol = pricefeed.symbol;
      console.log(`${timestamp}: ${symbol}: ${price}`);

      try {
        await insertPrice(pricefeed.symbol, new Date(timestamp * 1000), price);
        await producer.send({
          topic: "pricefeed-topic",
          messages: [
            {
              key: symbol,
              value: JSON.stringify({ symbol, timestamp, price }),
            },
          ],
        });
      } catch (error) {
        console.log("Error handling pricefeed send", error);
      }
    }
  } catch (error) {
    console.log("Error fetching prices:", error);
    throw error;
  }
}

async function insertPrice(symbol: string, time: Date, price: number) {
  const query = `
      INSERT INTO pricefeed_real_time (time, symbol, price) 
      VALUES ($1, $2, $3)
  `;
  const values = [time, symbol, price];

  try {
    const res = await pool.query(query, values);
    // console.log("Inserted:", res.rowCount);
  } catch (err) {
    console.error("Error inserting data", err);
  }
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function retryOperation(operation: () => Promise<void>, retries: number, delayMs: number) {
  for (let i = 0; i < retries; i++) {
    try {
      await operation();
      return;
    } catch (error) {
      console.error(`Attempt ${i + 1} failed. Retrying in ${delayMs} ms...`);
      await delay(delayMs);
    }
  }
  throw new Error(`Operation failed after ${retries} retries`);
}

export async function main() {
  await producer.connect();
  // await client.connect();

  // Schedule the task to run every second
  const intervalId = setInterval(async () => {
    console.log(`Fetching prices at ${new Date().toISOString()}`);

    try {
      await retryOperation(fetchPricesPipeline, 5, 1000);
    } catch (error) {
      console.error("Failed to fetch prices after several attempts, restarting server...");
      await shutdown();
      process.exit(1);
    }
  }, (Number(process.env.UPDATE_INTERVAL_S) || 10) * 1000) as NodeJS.Timeout;

  // Graceful shutdown
  const shutdown = async () => {
    console.log("Shutting down...");
    clearInterval(intervalId); // Stop the interval
    await producer.disconnect(); // Disconnect the Kafka producer
    await pool.end(); // Close the database connection pool
    process.exit(0);
  };

  // Capture exit signals
  process.on("SIGINT", shutdown);
  process.on("SIGTERM", shutdown);
}
