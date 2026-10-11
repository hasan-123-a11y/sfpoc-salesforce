# CLAUDE.md — Project rules for Claude Code

## Project
Proof of Concept: AI-assisted, governed Salesforce delivery.
Flow: Jira (SFPOC) → Claude analysis → developer approval → source changes → GitHub PR → required checks → Gearset pipeline (DEV → UAT → PROD).
See `docs/architecture.md` (once it exists) for the full design.

## Your role
You are an AI development assistant, not a deployment bot. A human developer approves every plan and reviews every change.

## Mandatory workflow for any Jira ticket
1. Read the ticket (Jira via the Atlassian MCP, or text the developer pastes).
2. Produce a REQUIREMENT ANALYSIS before changing anything, using exactly these headings:
   - Business requirement
   - Acceptance criteria (list each, and flag anything ambiguous with a proposed interpretation)
   - Salesforce components (with exact API names and file paths)
   - Potential dependencies
   - Implementation plan (numbered steps)
   - Testing plan
   - Deployment risk: LOW / MEDIUM / HIGH (with reason)
   - Potential destructive changes: YES / NO
3. STOP and wait for explicit developer approval. Do not edit files before approval.
4. Implement only what was approved. If something unexpected comes up, stop and ask.
5. Show `git diff --stat` and explain each changed file: what changed, why, risks, dependencies.
6. Validate against DEV with a check-only dry run (see Commands). Never deploy for real.
7. Commit, push the feature branch and open a PR using `.github/pull_request_template.md`, filled in completely.
8. Never merge. The developer and the required checks decide.

## Conventions
- Branch: `feature/SFPOC-<n>-<short-lowercase-description>`, created from `develop`
- Commit: `SFPOC-<n> <imperative summary>`
- PR title: `SFPOC-<n> <story title>`, base branch `develop`
- Salesforce source format under `force-app/main/default`, API version from `sfdx-project.json`
- Field visibility through a permission set, never by editing profiles
- Keep changes minimal and focused on the ticket

## Commands
- Check-only validation against DEV:
  `sf project deploy start --source-dir force-app --dry-run --test-level NoTestRun`
- With Apex tests:
  `sf project deploy start --source-dir force-app --dry-run --test-level RunSpecifiedTests --tests <TestClass>`
- Retrieve from DEV: `sf project retrieve start --metadata "<Type>:<Name>"`

## Hard rules (also enforced by settings and GitHub)
- Never merge PRs, never push to `develop` or `main`, never force-push.
- Never deploy without `--dry-run`. Deployments happen only through Gearset.
- Never run `sf org login` or connect any other org. The CLI is connected to SFPOC_DEV only.
- Never read or print credentials, tokens or files under `~/.sf`, `~/.sfdx`, `.sf`, `.sfdx`.
- Never commit secrets, usernames, org IDs or company data. This repository is public.
- Never change `.github/`, `.claude/` or this file without explicit approval.
- Never add destructive changes (deletions) unless the developer explicitly approves them.
- Never disable tests, checks or security settings to make something pass.

## Documentation
- Jira holds requirements and acceptance criteria; link to them, never copy them.
- Confluence page per ticket: you may draft sections marked [Claude draft]; never edit [Human-owned] sections.
- Repository docs live in `docs/`.