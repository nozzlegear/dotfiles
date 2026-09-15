---
name: jj-log
description: Read and parse jj logs, commit messages, and descriptions. Use when the agent needs to inspect commit history, search for commits by message content or trailers, filter by author/date/branch, parse jj log output into structured data (subject, body, type/scope trailers), or navigate jj revision ranges. Triggered by requests to "show git log", "find commits with fix", "what changed in this branch", "list recent jj commits", or any history browsing task.
---

# jj-log

Read and parse `jj` commit history efficiently. Use structured queries to narrow the search space before reading full descriptions.

## When to use this skill

- Inspecting commit history: "show recent commits", "what did I change last week?"
- Searching by message content: "find commits with fix", "show all feature commits"
- Filtering by trailers: "list commits with type: refactor"
- Navigating revision ranges: "what's between @ and main?", "show divergent commits"
- Reading commit descriptions: "what's in this changeset?", "show description for @~2"

## Template reference

For the full template language reference, run `jj help -k templates`. Key keywords available in `jj log` templates: `commit_id`, `author()`, `description()`, `trailers()`, `date()`.

## Quick Start

```bash
# Recent commits
jj log -r "all()" --no-pager -n 20

# Commits by you
jj log -r "mine()" --no-pager

# Commits containing a keyword in the description
jj log -r 'description("fix")' --no-pager

# Commits with a specific trailer
jj log -r 'has_trailer("type: feature")' --no-pager

# Full description with trailers for a specific revision
jj log -r "@~3..@" --no-pager
```

## Template Examples

Use `-T` with template expressions to customize output. Always use `--no-pager -G`.

```bash
# Short ID + subject only
jj log -r "all()" -T 'self.commit_id().short() ++ " | " ++ self.description().first_line() ++ "\n"' --no-pager -G

# Subject + all trailers
jj log -r "all()" -T 'self.commit_id().short() ++ " | " ++ self.description().first_line() ++ " " ++ self.trailers().map(|t| t.key() ++ ": " ++ t.value()).join(" ") ++ "\n"' --no-pager -G

# Author + relative date + subject
jj log -r "all()" -T 'self.commit_id().short() ++ " | " ++ self.author().name() ++ " | " ++ self.author().timestamp().ago() ++ " | " ++ self.description().first_line() ++ "\n"' --no-pager -G

# Full description for a single commit
jj log -r "@" -T 'self.description() ++ "\n"' --no-pager -G
```

## Common Patterns

See [revsets.md](references/revsets.md) for the full revision syntax reference. Common patterns:

```bash
# Divergent commits (not ancestors of @)
jj log -r '..@' --no-pager

# Commits on a specific branch
jj log -r 'branch("main")' --no-pager

# Recent commits with type+scope trailers
jj log -r 'mine() && after("2 weeks ago")' --no-pager

# Commits touching a specific file
jj log -r 'files_changed(@, "path/to/file")' --no-pager

# Unmerged commits
jj log -r 'divergent()' --no-pager
```

## Tips

- Always use `--no-pager` to avoid TUI interference.
- Use `-r "REVSET"` to filter at the query level; never fetch all commits and filter manually.
- For single-commit descriptions, prefer `jj describe -r @` (shows nothing if already set) or `jj log -r @ --no-pager -p` (shows diff + description).
- Trailers in descriptions follow `key: value` format at the end of the description — parse them by reading backwards from the last line.
