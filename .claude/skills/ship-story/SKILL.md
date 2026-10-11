---
name: ship-story
description: Validate, commit, push and open the pull request for the current Jira story branch. Never merges.
argument-hint: [jira-key, e.g. SFPOC-1]
disable-model-invocation: true
---
Ship the approved work for $ARGUMENTS following CLAUDE.md. Never merge.

1. Confirm the current branch starts with feature/$ARGUMENTS- and show git status. Stop if not.
2. Show the changed files compared with develop and explain each one: what changed, why, risks, dependencies.
3. Check the changes for secrets, usernames, org IDs and company data. Stop if anything is found.
4. Run the check-only validation against DEV, including the agreed Apex tests if any. Stop and report if it fails.
5. Commit with the message "$ARGUMENTS <imperative summary>" and push with git push -u origin <branch>.
6. Create a PR into develop titled "$ARGUMENTS <Jira summary>". Fill .github/pull_request_template.md completely and honestly; leave "Git diff reviewed by the developer" unticked.
7. Add a comment to Jira issue $ARGUMENTS with the PR link.
8. Show the PR URL and run gh pr checks.
