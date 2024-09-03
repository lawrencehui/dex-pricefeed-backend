import React, { useState, useEffect } from "react";

const App: React.FC = () => {
  const [messages, setMessages] = useState<string[]>([]);
  const [filteredMessages, setFilteredMessages] = useState<string[]>([]);
  const [selectedSymbol, setSelectedSymbol] = useState<string>("All");

  useEffect(() => {
    const ws = new WebSocket("ws://localhost:31018");

    ws.onmessage = (event) => {
      const message = event.data;
      setMessages((prevMessages) => [...prevMessages, message]);
    };

    return () => {
      ws.close();
    };
  }, []);

  useEffect(() => {
    if (selectedSymbol === "All") {
      setFilteredMessages(messages);
    } else {
      setFilteredMessages(
        messages.filter((msg) => {
          const parsedMsg = JSON.parse(msg);
          return parsedMsg.symbol === selectedSymbol;
        })
      );
    }
  }, [selectedSymbol, messages]);

  return (
    <div>
      <h1>Price Feed</h1>
      <label htmlFor="symbol-select">Filter by Symbol: </label>
      <select id="symbol-select" value={selectedSymbol} onChange={(e) => setSelectedSymbol(e.target.value)}>
        <option value="All">All</option>
        <option value="XAU/USD">XAU/USD</option>
        <option value="PAXG/USD">PAXG/USD</option>
        <option value="ETH/USD">ETH/USD</option>
        <option value="BTC/USD">BTC/USD</option>
        <option value="XAG/USD">XAG/USD</option>
        <option value="XPT/USD">XPT/USD</option>
      </select>
      <ul>
        {filteredMessages.map((message, index) => (
          <li key={index}>{message}</li>
        ))}
      </ul>
    </div>
  );
};

export default App;
