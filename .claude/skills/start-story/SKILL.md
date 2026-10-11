---
name: start-story
description: Start work on a Jira story. Reads it, creates the feature branch and produces the requirement analysis, then stops for approval.
argument-hint: [jira-key, e.g. SFPOC-1]
disable-model-invocation: true
---
Start work on Jira issue $ARGUMENTS following CLAUDE.md.

1. Read $ARGUMENTS from Jira (site hasanlodhisandbox) via the Atlassian MCP. If it does not exist or is not in project SFPOC, stop and tell me.
2. If there are uncommitted changes, stop and ask. Otherwise switch to develop and pull.
3. Create the branch feature/$ARGUMENTS-<short-lowercase-description-from-the-summary> from develop. If it already exists, switch to it.
4. Inspect the relevant metadata in force-app (read only). Retrieve from DEV only if a component you need is missing locally.
5. Produce the REQUIREMENT ANALYSIS exactly as defined in CLAUDE.md. For every vague acceptance criterion, propose a concrete interpretation, for example how visibility is granted, whether an Apex test is needed so tests run in the pipeline, and where documentation goes.
6. Stop and wait for my approval. Do not edit files and do not change Jira.
