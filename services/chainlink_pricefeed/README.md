### Run service locally in docker

```
docker compose up --build
```

navigate to `localhost:31008/` for testing

### Price feed source

To add new on-chain pairs and get chainlink contract address:

Chainlink Datafeeds: [https://data.chain.link/feeds ](https://data.chain.link/feeds)

### TimescaleDB init

```
CREATE TABLE pricefeed_real_time (
  time TIMESTAMPTZ NOT NULL,
  symbol TEXT NOT NULL,
  price DOUBLE PRECISION NULL
);

SELECT create_hypertable('pricefeed_real_time', by_range('time'));

CREATE INDEX ix_symbol_time ON pricefeed_real_time (symbol, time DESC);
```

#### create the continuous aggregate

```
CREATE MATERIALIZED VIEW one_min_candle
WITH (timescaledb.continuous) AS
    SELECT
        time_bucket('1 minute', time) AS bucket,
        symbol,
        FIRST(price, time) AS "open",
        MAX(price) AS high,
        MIN(price) AS low,
        LAST(price, time) AS "close"
    FROM pricefeed_real_time
    GROUP BY bucket, symbol;
```

#### create the aggregate policy

```
SELECT add_continuous_aggregate_policy('one_min_candle',
    start_offset => INTERVAL '2 minutes',
    end_offset => NULL,
    schedule_interval => INTERVAL '30 seconds');
```

#### remove the aggregate policy

```
SELECT remove_continuous_aggregate_policy('one_min_candle');
```

#### query continuous aggregate

```
SELECT * FROM one_min_candle
WHERE symbol = 'BTC/USD' AND bucket >= NOW() - INTERVAL '120 minutes'
ORDER BY bucket;
```
