---
description: Commit staged changes, push branch, and open a PR with a structured description
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git branch --show-current:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*), Bash(git checkout -b:*)
---

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Staged diff summary: !`git diff --cached --stat`

## Your task

Using the diff and branch name above, perform these steps **in a single message**:

### 1. Ensure you are on a feature branch

If the current branch is `main`, `master`, `trunk`, or `develop`, create and switch to a new feature branch named after the JIRA ticket ID found in the staged commit context (e.g. `PRODENG-123`), or use a short descriptive slug if no ticket is identifiable.

### 2. Stage and commit

Stage all changes (`git add -A`) and create a single commit. Commit message format:

```
[TICKET-ID] <imperative verb> <what changed>
```

Extract `TICKET-ID` from the branch name using pattern `[A-Z]+-[0-9]+`. Omit the bracket prefix if no ticket ID is present. 72 characters max.

### 3. Push the branch

Push the branch to origin.

### 4. Construct the PR body

Extract `TICKET-ID` from the branch name (`[A-Z]+-[0-9]+`). Build the PR description using **exactly** this structure — no extra sections, no padding:

```markdown
## What
<One sentence: what does this PR do?>

## Why
<One sentence: why is this change needed?>

## How
<Bullet list of key implementation decisions; ≤5 bullets; omit obvious/mechanical steps>

## Testing
<How was this verified? One line per method>

## Links
- JIRA: [TICKET-ID](https://mirantis.jira.com/browse/TICKET-ID)

## Checklist
- [ ] Tests added or updated
- [ ] Docs updated if user-visible behaviour changed
- [ ] No debug output or dead code left in
```

**Constraints** (strictly enforced):
- What + Why combined: ≤ 50 words
- How: ≤ 5 bullets, each ≤ 15 words
- Testing: ≤ 3 lines
- Total body: ≤ 250 words
- If no JIRA ticket found: set Links to `- JIRA: N/A`

PR title format: `[TICKET-ID] <imperative verb> <what changed>` (72 chars max, same as commit subject).

### 5. Open the PR

Run `gh pr create` with `--title` and `--body` set to the values constructed above. Do not use `--fill`.

Do all of the above in a single message using parallel tool calls where possible. Do not ask for confirmation at intermediate steps.
