import * as dotenv from "dotenv";
import express from "express";
import { main as startPriceFetching } from "./runPriceFetching";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 31008;

app.use(express.json());

app.get("/", async (req, res) => {
  res.send({ message: "welcome to chainlink pricefeed" });
});

app.get("/test", async (req, res) => {
  res.send({ message: "whatsup test!" });
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);

  startPriceFetching().catch((error) => {
    console.error("Error in price fetching:", error);
    process.exit(1);
  });
});
