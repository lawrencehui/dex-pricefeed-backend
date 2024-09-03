import * as dotenv from "dotenv";
import express from "express";
import { Kafka, Consumer } from "kafkajs";
import WebSocket, { WebSocketServer } from "ws";

dotenv.config();

// const app = express();
// const PORT = process.env.PORT || 31018;

// app.use(express.json());

// app.get("/", async (req, res) => {
//   res.send({ message: "welcome to ws services" });
// });

// app.get("/test", async (req, res) => {
//   res.send({ message: "whatsup test!" });
// });

// app.listen(PORT, () => {
//   console.log(`Server is running on http://localhost:${PORT}`);
// });

// Initialize Kafka consumer
const kafka = new Kafka({ clientId: "trex-ws-services", brokers: ["localhost:9092"] });
const consumer: Consumer = kafka.consumer({ groupId: "pricefeed-group" });

// Initialize WebSocket server
const wss = new WebSocketServer({ port: 31018 });

const run = async () => {
  await consumer.connect();
  await consumer.subscribe({ topic: "pricefeed-topic", fromBeginning: false });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const messageValue = message.value?.toString();
      console.log(`Received message: ${messageValue}`);

      // Broadcast the message to all connected WebSocket clients
      wss.clients.forEach((client: WebSocket) => {
        if (client.readyState === WebSocket.OPEN && messageValue !== undefined) {
          client.send(messageValue);
        }
      });
    },
  });
};

run().catch(console.error);

wss.on("connection", (ws) => {
  console.log("New WebSocket connection");
  ws.on("message", (message) => {
    console.log(`Received from client: ${message}`);
  });
});
