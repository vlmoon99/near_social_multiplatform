const WebSocket = require('ws');

const server = new WebSocket.Server({ port: 8080 });
const connections = new Map();

server.on('connection', (ws) => {
  const userId = Math.random().toString(36).substring(7);
  connections.set(userId, ws);

  ws.on('message', (message) => {
    const data = JSON.parse(message);

    connections.forEach((client, id) => {
      if (id !== userId && client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ userId, vector: data }));
      }
    });
  });

  ws.on('close', () => {
    connections.delete(userId);
  });

  console.log(`User ${userId} connected`);
});

console.log('WebSocket server is running on ws://localhost:8080');
