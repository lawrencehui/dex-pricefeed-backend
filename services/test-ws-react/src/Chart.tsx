import React, { useEffect, useRef, useState } from "react";
import { createChart, ISeriesApi, BarData, Time, TimeScaleOptions } from "lightweight-charts";

const App: React.FC = () => {
  const chartContainerRef = useRef<HTMLDivElement>(null);
  const chartRef = useRef<ISeriesApi<"Candlestick"> | null>(null);
  const [selectedSymbol, setSelectedSymbol] = useState<string>("BTC/USD"); // Default to BTC/USD
  const [selectedInterval, setSelectedInterval] = useState<string>("1 minute"); // Default to 1 minute

  useEffect(() => {
    if (chartContainerRef.current) {
      const chart = createChart(chartContainerRef.current, {
        width: chartContainerRef.current.clientWidth,
        height: 400,
      });

      chart.timeScale().applyOptions({
        timeVisible: true, // Show time on the x-axis
        secondsVisible: true, // Show seconds if needed
        tickMarkFormatter: (time, tickMarkType, locale) => {
          // console.log("time", time);
          // console.log("tickMarkType", tickMarkType);

          const date = new Date((time as any) * 1000);
          const hoursAndMinutes = date.toLocaleString(locale, { hour: "2-digit", minute: "2-digit" });

          if (tickMarkType === 0 || tickMarkType === 1 || tickMarkType === 2) {
            return date.toLocaleDateString(locale, {
              // year: "numeric",
              month: "short",
              day: "numeric",
            });
          }

          return hoursAndMinutes;
        },
      } as TimeScaleOptions);

      const candlestickSeries = chart.addCandlestickSeries({
        upColor: "#26a69a",
        downColor: "#ef5350",
        borderVisible: false,
        wickUpColor: "#26a69a",
        wickDownColor: "#ef5350",
      });

      chartRef.current = candlestickSeries;

      // Fetch initial data from /getLast60bars
      const fetchInitialData = async () => {
        const response = await fetch("http://127.0.0.1:31028/getLast60bars", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            symbol: selectedSymbol,
            interval: selectedInterval,
          }),
        });
        const data = await response.json();

        const convertedData = data.map((bar: any) => ({
          time: (new Date(bar.time).getTime() / 1000) as Time, // Convert to UNIX timestamp in seconds
          open: bar.open,
          high: bar.high,
          low: bar.low,
          close: bar.close,
        }));

        console.log("fetchInitialData", convertedData);

        candlestickSeries.setData(convertedData);
        chart.timeScale().fitContent();
      };

      fetchInitialData();

      let currentCandle: BarData | null = null;

      const ws = new WebSocket("ws://localhost:31018");

      ws.onmessage = (event) => {
        const message = JSON.parse(event.data);
        if (message.symbol === selectedSymbol) {
          // Calculate the start of the current interval based on the selected interval
          let bucketDuration;
          switch (selectedInterval) {
            case "1 minute":
              bucketDuration = 60; // 60 seconds
              break;
            case "2 minutes":
              bucketDuration = 120; // 120 seconds
              break;
            case "5 minutes":
              bucketDuration = 300; // 300 seconds
              break;
            case "10 minutes":
              bucketDuration = 600; // 600 seconds
              break;
            case "30 minutes":
              bucketDuration = 1800; // 1800 seconds
              break;
            case "1 hour":
              bucketDuration = 3600; // 3600 seconds
              break;
            case "4 hours":
              bucketDuration = 14400; // 14400 seconds
              break;
            case "1 day":
              bucketDuration = 86400; // 86400 seconds
              break;
            default:
              bucketDuration = 60; // Default to 1 minute if interval is unknown
          }

          const time: Time = (Math.floor(message.timestamp / bucketDuration) * bucketDuration) as Time; // start of the minute

          if (!currentCandle || currentCandle.time !== time) {
            if (currentCandle) {
              candlestickSeries.update(currentCandle);
              // Scroll to the latest data
              chart.timeScale().scrollToRealTime();
            }
            currentCandle = {
              time,
              open: message.price,
              high: message.price,
              low: message.price,
              close: message.price,
            };
          } else {
            currentCandle.high = Math.max(currentCandle.high, message.price);
            currentCandle.low = Math.min(currentCandle.low, message.price);
            currentCandle.close = message.price;
            candlestickSeries.update(currentCandle);
          }
        }
      };

      ws.onerror = (error) => {
        console.error("WebSocket error observed:", error);
      };

      ws.onclose = (event) => {
        console.log("WebSocket connection closed");
        console.log("Code:", event.code, "Reason:", event.reason, "WasClean:", event.wasClean);
      };

      return () => {
        ws.close();
        chart.remove();
      };
    }
  }, [selectedSymbol, selectedInterval]);

  return (
    <div style={{ margin: "36px" }}>
      <select id="symbol-select" value={selectedSymbol} onChange={(e) => setSelectedSymbol(e.target.value)}>
        <option value="BTC/USD">BTC/USD</option>
        <option value="ETH/USD">ETH/USD</option>
        <option value="XAU/USD">XAU/USD</option>
        <option value="PAXG/USD">PAXG/USD</option>
        <option value="XAG/USD">XAG/USD</option>
        <option value="XPT/USD">XPT/USD</option>
      </select>
      <select id="interval-select" value={selectedInterval} onChange={(e) => setSelectedInterval(e.target.value)}>
        <option value="1 minute">1 minute</option>
        <option value="2 minutes">2 minutes</option>
        <option value="5 minutes">5 minutes</option>
        <option value="10 minutes">10 minutes</option>
        <option value="30 minutes">30 minutes</option>
        <option value="1 hour">1 hour</option>
        <option value="4 hours">4 hours</option>
        <option value="1 day">1 day</option>
      </select>
      <div ref={chartContainerRef} style={{ position: "relative", width: "100%", height: "400px", margin: "12px" }} />
    </div>
  );
};

export default App;
