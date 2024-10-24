# DEX Oracle Pricefeed System

This repository contains a real-time price feed system that integrates Chainlink price feeds, Kafka, TimescaleDB, WebSockets, and a React frontend with the TradingView charting library. The system is designed to fetch price data every second, relay real-time price updates to WebSocket clients, and support querying historical price data.

## Architecture Overview

The system consists of the following components:

1. **Chainlink Pricefeed Service**: Fetches price quotes every second from Chainlink and publishes them to a Kafka instance while also inserting the data into a TimescaleDB cloud database.
2. **Kafka (Docker instance)**: Acts as the message broker, receiving real-time price data from the Chainlink pricefeed service and forwarding it to consumers, including the WebSocket service.

3. **TimescaleDB Cloud Database**: Stores the price data for historical querying and timebucket aggregation.

4. **WebSocket Server**: Consumes the price feed from Kafka and relays real-time price updates to WebSocket clients.

5. **Timescale API Server**: Provides an API to query historical price data from the TimescaleDB, supporting timebucket aggregation for efficient querying.

6. **React Frontend**: A demo frontend that uses the TradingView charting library to display both historical and real-time price data. Real-time updates are delivered via WebSocket, while historical data is fetched via the Timescale API.

7. **Terraform**: Infrastructure as code to deploy the entire architecture onto AWS. Each microservice can be deployed using Docker Compose.

---

## Architecture Diagram

```
+------------------------------------------------------------+
|                        AWS Cloud                           |
|  +----------------------------------------------------+    |
|  |                                                    |    |
|  |     +----------------------+                       |    |
|  |     | Chainlink Pricefeed  |                       |    |
|  |     | Service (Docker)     |                       |    |
|  |     +----------+-----------+                       |    |
|  |                |                                   |    |
|  |                v                                   |    |
|  |     +----------------------+                       |    |
|  |     |      Kafka           |                       |    |
|  |     |    (Docker)          |                       |    |
|  |     +----------+-----------+                       |    |
|  |                |                                   |    |
|  |                v                                   |    |
|  |  +--------------------------+                      |    |
|  |  |     WebSocket Server     |                      |    |
|  |  | (Real-Time Price Feed)   |                      |    |
|  |  +--------------------------+                      |    |
|  |                |                                   |    |
|  |                v                                   |    |
|  |        +----------------+                          |    |
|  |        |   WebSocket    |                          |    |
|  |        |     Clients    |                          |    |
|  |        +----------------+                          |    |
|  |                                                    |    |
|  +----------------------------------------------------+    |
|  |                                                    |    |
|  |  +--------------------------------------------+    |    |
|  |  |                                            |    |    |
|  |  |       TimescaleDB (Cloud)                  |    |    |
|  |  |   (Stores historical price data)           |    |    |
|  |  +--------------------------------------------+    |    |
|  |                |                                   |    |
|  |                v                                   |    |
|  |  +-----------------------------+                   |    |
|  |  | Timescale API Service       |                   |    |
|  |  | (Historical Price Query)    |                   |    |
|  |  +-----------------------------+                   |    |
|  |                                                    |    |
|  +----------------------------------------------------+    |
|                ^                                           |
|                |                                           |
|  +------------------------------+                          |
|  |                              |                          |
|  |  React Frontend (TradingView)|                          |
|  |   (Real-time & Historical)   |                          |
|  |   - Connects to WebSocket    |                          |
|  |   - Pings Timescale API      |                          |
|  +----------------------------+                            |
+------------------------------------------------------------+
```

---

## Folder Structure

```
monorepo_root
│
├── scripts/             # Helper scripts for setup and maintenance
├── services/
│   ├── chainlink_pricefeed/    # Chainlink price fetching service
│   ├── kafka/                  # Kafka Docker setup
│   ├── test-ws-react/          # React frontend using TradingView
│   ├── timescale_api/          # TimescaleDB API server for historical data
│   ├── ws_services/            # WebSocket server for real-time data feed
├── terraform/           # Terraform setup for AWS deployment
```

## Services

1. **Chainlink Pricefeed Service**

   - This service fetches price quotes from Chainlink every second.
   - It publishes the price data to Kafka and stores it in TimescaleDB for historical querying.

2. **Kafka**

   - Acts as the message broker for real-time price data.
   - Microservices such as the WebSocket server and Timescale API consume the data for real-time and historical processing.

3. **WebSocket Service**

   - Consumes real-time price data from Kafka and relays it to WebSocket clients for live updates.

4. **Timescale API**

   - Queries historical price data stored in TimescaleDB, supporting timebucket aggregation for efficient data retrieval.

5. **Demo React Frontend**
   - Displays real-time and historical price data on a chart using TradingView.
   - Connects to the WebSocket server for live updates and fetches historical data via the Timescale API.

## Deployment

The entire architecture is deployed on AWS using Terraform. Each microservice includes a `docker-compose.yml` file for easy local and cloud-based deployment.

### Terraform Setup

To deploy the infrastructure on AWS:

1. Navigate to the `terraform/` directory.
2. Run the following commands to set up the AWS infrastructure:
   ```
   terraform init
   terraform apply
   ```

### Docker Compose

Each service can be started locally using Docker Compose. For example, to run the WebSocket service:

```bash
cd services/ws_services
docker-compose up
```

Similarly, repeat the process for the other services.

---

## Frontend Setup

The frontend is built using React and integrates the TradingView charting library to display both real-time and historical price data.

To run the frontend:

```bash
cd services/test-ws-react
yarn
yarn start
```

---

## API Documentation

- **Timescale API**: Provides endpoints for querying historical price data.
  - Example:
  ```
  GET /api/v1/prices?start=2024-01-01&end=2024-01-31&timebucket=1h
  ```

---

## License

This project is licensed under the MIT License.
