const axios = require('axios');
async function simulateError() {
  try {
    await axios.get('http://localhost:3000/error');
  } catch (e) {
    if (e.response && e.response.data) {
      console.log('Error simulated:', e.response.data);
    } else {
      console.log('Error occurred:', e.message);
    }
    // Here you can add code to create a ticket (e.g., GitHub Issue, JIRA)
  }
}
simulateError();
