---
name: jj-describe
description: Analyze the changes in the current Jujutsu (jj) changeset and give it a clear, concise description with type and scope trailers. Use when the user asks to describe a change or commit.
---

This command analyzes the changes in the current jj changeset and creates a clear, concise changeset description. It reviews the changes, categorizes the nature and scope, and then saves the description without asking for confirmation.

## Target changeset

The user should have given instructions on which changeset they want you to describe. If it's the current changeset, you can use `@` as the changeset id; otherwise, use the exact changeset id you were given. Note: you **do not** need to be on the changeset to describe it, i.e. you can describe changeset *B* or *C* even when you're on changeset *A* or *@* – jj does not require you to move to those changesets first before describing them.

If you're describing more than one changeset, you should iterate through them one at a time and follow these instructions to describe each one.

If you're unsure of which changeset you should describe, you should stop and ask.

## Workflow

1. Run `jj status --no-pager -r changeset_id` to get the changeset state.
    - Skip this step if the user has already given you the changeset state.
2. Run `jj diff --git --stat --no-pager -r changeset_id` to list the files changed in the changeset.
    - Skip this step too if the user has already given you a list of the files changed.
3. Decide whether you should review a full diff of all files in the changeset at once, or a diff of individual files.
    - Use `jj diff --git --no-pager -r changeset_id` to review a diff of all files at once.
    - Use `jj diff --git --no-pager -r changeset_id file_1.txt [file_2.txt ...]` to review a diff of one or more files.
3. Once you've diffed the entire changeset, analyze the type of changes:
   - Feature additions (type: feature)
   - Existing feature enhancement (type: enhancement)
   - Refactor (type: refactor)
   - Bug fixes (type: fix)
   - Documentation (type: docs)
   - Style changes (type: style)
   - Refactoring (type: refactor)
   - Tests (type: test)
   - Chores (type: chore)
5. Use `jj describe -r changeset_id -m "message_here"` to write a description message with:
   - A subject line (the first line of the description) that uses present tense, imperative mood description
   - A body (any line beyond the first line) that uses past tense, indicative mood.
   - The body should explain "why" the change was made and to "what"
   - The "footer" of the body should contain references, if applicable
   - The last two lines of the body are the git trailers, which describe the type and scope of the changes (e.g. `type: fix` and `scope: database`)
   - You can also use `--stdin` instead of `-m "message here"` to pass the description message via stdin.

## Example description messages
### Example 1: Simple feature commit
```
Add password reset functionality

Implemented the Forgot Password flow with a 24h expiry for the Password Reset tokens.
Added the Email Notification service.

type: feature
scope: auth
```

### Example 2: Bug fix commit
```
Resolve null pointer in user validation

Validation was failing when optional fields were undefined.
Added null checks before accessing nested properties.

Fixes #123

type: fix
scope: auth
```

## Notes
- Keep subject line under 80 characters
- Reference issues/PRs when relevant
- Always use American English when writing a commit message.
- Do NOT list the files that were changed in commit messages or bodies.
- Do NOT add Claude co-authorship footer to commit messages or bodies.
- Do NOT prefix description messages with the "conventional commits" standard.
