---
name: realtime-patterns
description: WebSocket, Server-Sent Events, polling, and live update patterns
---

# Real-time Patterns

## WebSocket on Same Port as Express
```javascript
import express from 'express';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';

const app = express();
const server = createServer(app);
const wss = new WebSocketServer({ server });

// Shared HTTP + WebSocket on port 3001
app.use(express.json());

// REST endpoints...
app.get('/api/status', (req, res) => res.json({ status: 'ok' }));

// WebSocket handling
wss.on('connection', (ws) => {
  console.log('Client connected');
  ws.on('message', (data) => {
    // Handle incoming messages
  });
});

// Broadcast to all connected clients
function broadcast(message) {
  const data = JSON.stringify(message);
  wss.clients.forEach(client => {
    if (client.readyState === 1) client.send(data);
  });
}

server.listen(3001);
```

## Frontend WebSocket Hook
```javascript
const connect = () => {
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  const ws = new WebSocket(`${protocol}//${window.location.host}/ws`);

  ws.onopen = () => setConnected(true);
  ws.onclose = () => {
    setConnected(false);
    // Reconnect after 3 seconds
    setTimeout(connect, 3000);
  };

  ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    onMessage(data);
  };
};
```

## Polling (Simpler Alternative)
```javascript
// Poll every 5 seconds
useEffect(() => {
  const interval = setInterval(async () => {
    const data = await fetch('/api/status').then(r => r.json());
    setStatus(data);
  }, 5000);
  return () => clearInterval(interval);
}, []);
```

## When to Use What
| Pattern | Use Case |
|---------|----------|
| WebSocket | Chat, live feeds, real-time collaboration |
| Server-Sent Events | One-way server→client updates |
| Polling | Infrequent updates, simpler setup |

## Broadcast Events (Common Pattern)
```javascript
// On the server when data changes
broadcast({ type: 'ITEM_UPDATED', data: { id: 1, name: 'Updated' } });

// Frontend handles by type
ws.onmessage = (event) => {
  const { type, data } = JSON.parse(event.data);
  switch(type) {
    case 'ITEM_UPDATED': refreshItem(data); break;
    case 'NEW_MESSAGE': addMessage(data); break;
  }
};
```