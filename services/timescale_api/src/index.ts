import * as dotenv from "dotenv";
import express from "express";
import cors from "cors";
import { Pool } from "pg";

dotenv.config();

// PostgreSQL (TimescaleDB) connection setup
const pool = new Pool({
  connectionString: process.env.TIMESCALE_DB_CONNECTION_URI,
});

const app = express();
const PORT = process.env.PORT || 31018;
app.use(cors());
app.use(express.json());

app.get("/", async (req, res) => {
  res.send({ message: "welcome to ws services" });
});

app.get("/test", async (req, res) => {
  res.send({ message: "whatsup test!" });
});

// Define the route to get the last 60 bars from the one_min_candle view
app.post("/getLast60bars", async (req, res) => {
  const { symbol, interval } = req.body;

  console.log("symbol", symbol);
  console.log("interval", interval);

  // Validate the params body
  if (!symbol || typeof symbol !== "string" || !interval || typeof interval !== "string") {
    return res.status(400).send({ error: "Invalid symbol or interval parameter" });
  }

  try {
    const query = `
    SELECT
      time_bucket($2::interval, time) AS bucket,
      symbol,
      first(price, time) AS open,
      max(price) AS high,
      min(price) AS low,
      last(price, time) AS close
    FROM
      pricefeed_real_time
    WHERE
      symbol = $1
      AND time >= NOW() -  ($2::interval * 60)
    GROUP BY
      bucket, symbol
    ORDER BY
      bucket ASC
    LIMIT 60;
  `;

    // //   using materialised view
    //   const query = `
    //   SELECT * FROM one_min_candle
    //   WHERE symbol = 'BTC/USD' AND bucket >= NOW() - INTERVAL '6 hours'
    //   ORDER BY bucket;
    // `;

    const result = await pool.query(query, [symbol, interval]);

    const renamedResult = result.rows.map((row) => {
      return {
        ...row,
        time: row.bucket,
      };
    });
    // console.log("pinging /getLast60bars");

    console.log(`pinging /getLast60bars with symbol=${symbol} and interval=${interval}`);

    res.json(renamedResult);
  } catch (err) {
    console.error("Error querying the database:", err);
    res.status(500).send("Internal Server Error");
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
