# sfpoc-salesforce — AI-assisted Salesforce SDLC (Proof of Concept)

This repository demonstrates a governed, source-driven Salesforce delivery process:

**Jira → Claude-assisted development → GitHub Pull Request → automated quality gates → Gearset CI/CD → DEV → UAT → approved Production deployment**

It is a proof of concept intended to replace manual Change Set deployments.

> ⚠️ **Demo repository.** It contains only demo metadata for the PoC. It must never contain company metadata, data, usernames, org IDs, credentials, or secrets. No real Production org is used.

## Demo feature

| Item | Value |
|---|---|
| Jira story | `TJDG-1` — Create Account Health Status |
| Change | `Account.Health_Status__c` picklist (Healthy, At Risk, Critical), added to the Account layout |

## Branching

| Branch | Purpose | Deploys to (via Gearset) |
|---|---|---|
| `feature/TJDG-<n>-<description>` | One Jira issue, created from `develop` | — (validated against DEV) |
| `develop` (default) | Integration | DEV |
| `release/<name>` | Release candidate, created by Gearset | UAT |
| `main` | Production-ready | PROD (after approval) |

Direct pushes to `develop` and `main` are blocked. All changes arrive through Pull Requests.

## Conventions

- Commit: `TJDG-<n> <imperative summary>` — e.g. `TJDG-1 Add Account Health Status`
- Pull Request title: `TJDG-<n> <story title>`
- Every Pull Request uses the template in `.github/pull_request_template.md`

## Repository structure

```
force-app/main/default/   Salesforce metadata in source format
config/                   Scratch org definition (optional use)
docs/                     Architecture and process documentation
.github/                  Pull Request template and workflows
```

## Local development (summary)

```bash
# check-only validation against the DEV org (nothing is saved)
sf project deploy start --source-dir force-app --dry-run --test-level NoTestRun
```

The developer machine is connected to the DEV org only. UAT and PROD are reachable exclusively through Gearset.