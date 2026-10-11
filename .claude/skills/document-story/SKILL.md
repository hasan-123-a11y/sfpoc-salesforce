---
name: document-story
description: Create or update the Confluence page for a Jira story
argument-hint: [jira-key, e.g. SFPOC-1]
disable-model-invocation: true
---
Create or update the Confluence page for $ARGUMENTS following CLAUDE.md. Never publish without approval.

1. Read Jira issue $ARGUMENTS, including all comments. If it is not in project SFPOC, stop.
2. Find its pull requests with gh pr list --state all --search "$ARGUMENTS" and read each one with gh pr view and gh pr diff.
3. Find the page "$ARGUMENTS – <summary>" in space SFPOC, using the trimmed Jira summary and an en dash (–). If it does not exist, it will be created at the top level of the space.
4. Write the page using exactly the structure below. Keep every heading and table column, in this order. If a section does not apply to the story, keep the heading and write "Not applicable." with a short reason.
5. Show a short summary of the page (create or update, sections filled, cells left empty) and wait for my approval.
6. After approval, publish the page and add a comment on Jira issue $ARGUMENTS with the page link.

## Rules

- Facts only from the Jira issue and its comments, the pull requests and their diffs. Do not invent anything.
- Leave a cell empty when something is unknown.
- Never fill in UAT sign-off, approvals or decisions. Humans do.
- No labels such as [Claude draft] or [Human-owned] anywhere on the page.
- No Salesforce usernames, emails, org IDs, deploy IDs, record IDs or secrets.
- Keep the page title and the Jira issue macro. When updating an existing page, keep the title unchanged.
- Link to Jira for requirements; do not copy the story text.

## Page structure

Title: `$ARGUMENTS – <Jira summary>`

### Document control

Two-column table (field, value):

| Field | Value |
| --- | --- |
| Jira issue | Link to $ARGUMENTS |
| Release | Jira fix version, otherwise empty |
| Status | Based on the Jira status and the PR merge state, otherwise empty |
| Owner | Jira assignee, otherwise empty |
| Last updated | Date of publishing |
| Note | Prepared with AI assistance and reviewed by the developer. |

Directly below the table: the Jira issue macro for $ARGUMENTS.

### 1. Overview

One paragraph: what the release adds, the business reason, and how access and placement work.

### 2. Requirements and acceptance criteria

Sentence: "The user story and acceptance criteria are maintained in Jira issue $ARGUMENTS. The table below shows how each criterion is met."

| # | Acceptance criterion | How it is met | Verified by |
| --- | --- | --- | --- |

### 3. Solution design

#### 3.1 Data model

| Label | API name | Type | Values | Default | Restricted | Help text |
| --- | --- | --- | --- | --- | --- | --- |

Followed by notes on required, history tracking and restrictions.

#### 3.2 Security

Bullets: permission sets and what they grant; profiles changed or not. Followed by who can see the change until access is assigned.

#### 3.3 User interface

Layouts, sections, placement and editability.

### 4. Components

| Component | Metadata type | Change | Path |
| --- | --- | --- | --- |

### 5. Dependencies and assumptions

Bullets.

### 6. Testing

#### 6.1 Automated tests

What each test class asserts, then:

| Validation | Result |
| --- | --- |

#### 6.2 User acceptance test

Numbered test steps, then "Sign-off:" and this table with two empty rows. Never fill it in.

| Tester | Date | Result | Comments |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |

### 7. Deployment history

| Environment | Branch | Date | Method | Result |
| --- | --- | --- | --- | --- |
| DEV | `develop` |  |  |  |
| UAT |  |  |  |  |
| PROD | `main` |  |  |  |

Followed by a bullet list of the pull requests (number, title, link, source and target branch).

### 8. Post-deployment steps

Numbered manual steps per environment (DEV, UAT, PROD).

### 9. Rollback plan

Options from least to most invasive. Any rollback goes through a pull request into `develop` and the Gearset pipeline. Mark destructive options clearly.

### 10. Known issues and risks

Bullets, each starting with a short bold title.

### 11. References

- Jira: link to $ARGUMENTS
- Pull request(s): links
- Release pull request: link, if any
- Release notes: link, if any
- Repository: https://github.com/hasan-123-a11y/sfpoc-salesforce
