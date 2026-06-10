---
title: 'Review Pull Request'
read_only: true
type: 'command'
---

Review a GitHub pull request using the DijonBot MCP. Fetches the PR diff, analyzes it (using a subagent for large diffs), checks prior review comments to see if they were addressed, leaves inline comments, and submits the review as either an approval or a request for changes.

## Description

This command performs a thorough code review of a pull request by:
- Fetching the PR details and full file diff via the DijonBot MCP
- Spawning a subagent to read and analyze large diffs without consuming main context
- Checking any previous review comments to confirm whether they were addressed
- Starting a pending (draft) review, then adding focused inline comments
- Submitting the review as APPROVE or REQUEST_CHANGES based on findings

## Usage
`review` — reviews the PR for the current branch (inferred from `gh pr view`)
`review <PR number>` — reviews a specific PR number in the current repo

## Steps

1. **Identify the PR**
   - If a PR number is given, use it directly.
   - Otherwise run `gh pr view --json number,headRepository` to find the open PR for the current branch.
   - Extract the repo owner and name from the result.

2. **Fetch PR context in parallel**
   - `mcp__dijon-github-bot__get_pull_request` — title, description, state, TODO list
   - `mcp__dijon-github-bot__list_pull_request_files` — full diff with all changed files
   - `mcp__dijon-github-bot__get_pending_review` — check if a draft review already exists (avoid duplicates)

3. **Analyze the diff**
   - If the diff fits comfortably in context (< ~2,000 lines), read and analyze it directly.
   - If it is large (> ~2,000 lines), spawn a subagent (type: Explore or general-purpose) with the saved diff file path and instruct it to:
     - Read the file in chunks of ~155 lines using offset/limit until all lines are read
     - Return: all changed file paths, bugs/logic errors with verbatim code quotes, security issues, incomplete TODOs, and anything inconsistent with the PR description
   - When checking a revised PR (previous review existed), include the prior issues list in the subagent prompt and ask it to verify each one was addressed and flag any regressions introduced by the fixes.

4. **Determine exact line numbers for inline comments**
   - The diff file uses the format: `ADDED <path> (+N -0)` / `MODIFIED <path> (+N -M)` followed by `@@ -old,count +new,start @@` hunk headers.
   - For a new file (`@@ -0,0 +1,N @@`): file line = (diff file line of content) - (diff file line of first content line after hunk header) + 1
   - For a modified file: use the `+new,start` value from the hunk header as the base, then count `+` and ` ` (context) lines from that hunk to reach the target line.
   - Grep the diff file for the relevant code snippet to find its diff-file line number, then calculate the new-file line number using the hunk header.

5. **Start the review**
   - If `get_pending_review` returned a review, use that `review_node_id` for comments. Otherwise call `mcp__dijon-github-bot__start_review` to create a new pending review.

6. **Add inline comments**
   - Call `mcp__dijon-github-bot__add_review_comment` for each issue found.
   - Use the `path` (repo-relative file path) and `line` (new-file line number, RIGHT side) from step 4.
   - Focus comments on: correctness bugs, security issues, resource leaks, behavior that contradicts the PR description, and misleading or broken tests.
   - Skip style nits unless they indicate a deeper problem.
   - For multi-line issues, use `start_line` + `line` to span the range.

7. **Submit the review**
   - Call `mcp__dijon-github-bot__submit_review` with:
     - `event: "APPROVE"` if all must-fix issues are resolved (or none were found)
     - `event: "REQUEST_CHANGES"` if there are unresolved bugs or correctness issues
     - `event: "COMMENT"` for informational-only reviews with no blocking issues
   - Write a top-level `body` summarizing: what was checked, what was fixed (on re-review), what still needs attention, and any non-blocking nits.

## Decision criteria

**Request changes if:**
- A bug will cause incorrect behavior, silent data loss, or a crash in production
- A security vulnerability is introduced
- The implementation contradicts the stated PR goals in a material way
- An open TODO in the checklist is blocking correctness (not cosmetic)

**Approve if:**
- All previous request-changes issues are resolved
- No new must-fix bugs were introduced by the fixes
- Remaining issues are nits or pre-existing problems not introduced by this PR

## Judgment: thoroughness vs. nitpicking

The goal is to catch things that matter — not to find something to comment on. A PR that is safe, correct, and well-tested should be approved promptly. Before leaving a comment, ask: *would a reasonable developer want to know this before merging?* If the answer is "maybe, but it won't affect users or correctness," skip it.

**Comment on:**
- Bugs that will cause wrong behavior, data loss, crashes, or security issues in production
- Resource leaks or patterns that degrade reliability under real load
- Tests that don't actually test what they claim to (false confidence)
- Behavior that directly contradicts what the PR description says will happen

**Do not comment on:**
- Formatting, indentation, or whitespace (unless the project has a linter that enforces it)
- Naming preferences or style choices when the code is already clear
- "I would have done it differently" observations with no concrete downside
- Pre-existing issues in unchanged code — note them at most in the summary, never block on them
- Speculative future problems ("what if someday someone...") with no realistic near-term path

When in doubt, leave it out. One well-placed comment on a real bug is worth more than five comments on minor things, and excessive nitpicking erodes trust in the review process.

## Notes
- Always check `get_pending_review` before `start_review` to avoid creating duplicate draft reviews
- Inline comment `line` numbers are new-file line numbers (RIGHT side). For removed lines, use `side: "LEFT"` and the old-file line number.
- The diff file format from DijonBot uses `MODIFIED`/`ADDED`/`REMOVED` section headers, not `diff --git` headers — grep for those to find file boundaries.
- Large diffs (> 3,000 lines) should always use a subagent to keep the main context clean.
- On re-review, explicitly pass all prior issues to the subagent so it can confirm each one was addressed. Do not assume fixes were made.
- Pre-existing issues in files touched by the PR are not introduced by this PR — do not block approval for them.
