const express = require('express');
const app = express();
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Node.js microservice!' });
});

app.get('/error', (req, res) => {
  // Simulate error for monitoring/demo
  res.status(500).json({ error: 'Simulated error' });
});

const port = process.env.PORT || 3000;

// Only start server if this file is run directly (not imported for testing)
if (require.main === module) {
  app.listen(port, () => {
    console.log(`App listening on port ${port}`);
  });
}

module.exports = app;
