// Example: Create GitHub Issue automatically when error detected
const { Octokit } = require('octokit');
const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
async function createIssue(errorDetails) {
  await octokit.rest.issues.create({
    owner: 'your-org',
    repo: 'devops-demo',
    title: 'Automated Error Ticket',
    body: `Error detected: ${errorDetails}`
  });
}
module.exports = createIssue;
