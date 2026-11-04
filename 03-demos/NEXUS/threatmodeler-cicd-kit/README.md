# ThreatModeler CI/CD kit for GitHub Actions

Checks every pull request against the repository's threat model in
ThreatModeler Nexus, and records each merge in Nexus as a new version, with
requirement statuses set from the code.

Follow the **ThreatModeler CI/CD Integration Guide** to set it up. It walks
through every step below.

## Contents

| Folder | What it is |
|---|---|
| `kit/` | Copy its contents into the root of your repository: two workflows, a setup action, the agent instructions, and `.threatmodeler.yml`. |
| `sample-app/` | A small AWS service (load balancer, ECS, RDS, S3, KMS) to try the kit on in a test repository. |
| `sample-changes/` | Example changes to open as pull requests against the sample app: 1–3 are the guide's walkthrough; 4 (an export-jobs queue) and then 5 (its dead-letter queue) are extra changes for showing a model update and a new version live. |

## Requirements

- ThreatModeler Nexus 26.2 or later, with the MCP server and NexusAI.
- A GitHub organization repository with Actions enabled and `main` as the
  default branch.
- An Anthropic API key for the workflows.
- Claude Code (command line or VS Code extension), used once to create the
  baseline threat model over MCP.

## Workflows

| Workflow | Runs | Does |
|---|---|---|
| TM architecture check | Every pull request | Reviews the change against the threat model and comments on the PR; never changes Nexus |
| TM post-merge sync | Every merge; by hand with *apply* | Comments the expected model changes; with *apply*, adds them to the threat model, sets requirement statuses and saves version `pr-<n>-<sha7>` |
