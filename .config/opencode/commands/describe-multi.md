---
title: JJ Describe Multi Task
read_only: true
type: command
---

Iterate through multiple `jj` commits and generate well-structured descriptions for each.

## Description

This command analyzes a range of `jj` commits and creates clear, concise descriptions for each one. It reviews the changes per commit, categorizes the nature and scope, and saves the descriptions sequentially without asking for confirmation.

## Usage
`describe-multi <range>`

The range follows `jj log` syntax, e.g.:
- `vqvmtxny::tptvootx` — from commit vqvmtxny to tptvootx
- `abc123~5..abc123` — last 5 commits
- `::@~5` — 5 most recent commits

If no range is provided, defaults to all undescribed commits going backward from the working copy.

## Steps
1. Run `jj log -r '<range>' --color never` to list commits in the range
2. For each commit (starting from the oldest, working forward):
   a. Run `jj diff -r <change_id> -s` to see files changed
   b. Review the diff with `jj diff -r <change_id> --color never` if needed
   c. Analyze the type of changes:
      - Feature additions (type: feature)
      - Existing feature enhancement (type: enhancement)
      - Refactor (type: refactor)
      - Bug fixes (type: fix)
      - Documentation (type: docs)
      - Style changes (type: style)
      - Tests (type: test)
      - Chores (type: chore)
   d. Use `jj describe -r <change_id> -m "..."` to write the description
   e. **Wait for the rebase to complete** before proceeding to the next commit
3. Continue sequentially until all commits in the range are described

## Description format
- Subject line: present tense, imperative mood, under 80 characters
- Body: past tense, indicative mood explaining "why" and "what"
- Footer: type and scope trailers (e.g., `type: refactor` / `scope: build-config`)
- No file listings in messages
- American English

## Examples
### Example 1: E2E test addition
```
Add Playwright E2E regression tests with Testcontainers

Added Playwright configuration and initial E2E test scaffolding with
Testcontainers for CouchDB. Created auth spec, global setup/teardown,
and seed data.

type: test
scope: e2e
```

### Example 2: Refactor commit
```
Split constants into shared constants, client config, and server config

Created client_config.ts for build-time values read from Vite env.
Moved server-only configuration fields into server_config.ts.

type: refactor
scope: config
```

## Notes
- **Always describe commits sequentially, one at a time.** Running multiple `jj describe` commands in parallel causes divergent commit errors because each rewrites and rebases descendants.
- Use change IDs (e.g., `jj describe -r vqvmtxny -m "..."`) to target specific commits regardless of their commit ID changing after rebases.
- Start from the oldest commit in the range and work forward to avoid rebasing issues.
- Do NOT add Claude co-authorship footer to commit messages or bodies.
- Do NOT prefix description messages with the "conventional commits" standard.
