# jj Revision Syntax Reference

## Core Revision Operators

| Pattern | Meaning |
|---|---|
| `@` | Working copy (current changeset) |
| `@-` | Parent of working copy |
| `@--` | Grandparent |
| `root` | Root commit(s) |
| `all()` | All commits |
| `mine()` | Commits authored by you |
| `changed_in(REVSET)` | Commits whose content matches a revset |

## Range Operators

| Pattern | Meaning |
|---|---|
| `A..B` | Reachable from B but not A (B exclusive of A's ancestors) |
| `A..` | Reachable from @ but not A |
| `..B` | Reachable from B but not @ |
| `A::B` | Ancestors of B including A (ancestors range) |
| `A::` | Ancestors of @ |
| `::B` | Ancestors of B |
| `A..B..C` | Equivalent to `(A..B) || (B..C)` — union of two ranges |

## Filter Functions

| Function | Meaning |
|---|---|
| `author("name")` | Commits by author |
| `committer("name")` | Commits by committer |
| `after("2025-01-01")` | Commits after date |
| `before("2025-06-01")` | Commits before date |
| `description("fix")` | Commits whose description contains "fix" |
| `is:"commit"` / `is:"working-copy"` | Filter by commit type |
| `empty()` / `non_empty()` | By whether the diff is empty |
| `has_trailer("type: fix")` | Commits with a specific trailer |

## Combining Filters

Use boolean operators:

```
# Commits by you in the last week containing "fix"
mine() && after("1 week ago") && description("fix")

# All commits not in the current branch
all() .. @

# Commits on a specific branch
branch("main")

# Multiple conditions with AND/OR/NOT
author("alice") || author("bob")
!empty() && description("fix")
```

## Date Literals

- `"2025-01-15"` — specific date
- `"1 week ago"` — relative
- `"yesterday"`, `"today"`, `"tomorrow"`

## Useful Log Patterns

```bash
# Recent commits by you with trailers
jj log -r 'mine() && after("2 weeks ago")' -T '{commit_id.short()} {description().lines().filter(|s| s.contains(":")).join(" ")}\n'

# Find commits matching a trailer
jj log -r 'has_trailer("type: fix")'

# Divergent commits (not reachable from @)
jj log -r '..@' --no-pager

# All commits on a branch
jj log -r 'branch("feature-x")' --no-pager

# Commits that touched a specific file
jj log -r 'files_changed(@, ".config/nvim/lua/functions/apfel.lua")' --no-pager
```

## Template Keywords (Commit)

| Keyword | Type | Description |
|---|---|---|
| `commit_id` | CommitId | Full commit ID |
| `change_id` | ChangeId | Change ID |
| `author` | Author | Commit author |
| `committer` | Author | Commit committer |
| `root_commit` | Bool | Whether this is a root commit |
| `tags` | List<String> | Tags on this commit |
| `branches` | List<String> | Branch names |
| `description` | String | Full commit description |
| `working_copy` | Bool | Whether this is the working copy |

## Template Keywords (Author)

| Keyword | Type | Description |
|---|---|---|
| `name` | String | Author name |
| `email` | String | Author email |
| `username` | String | Author username |

## Template Keywords (Date)

| Keyword | Type | Description |
|---|---|---|
| `iso` | String | ISO 8601 timestamp |
| `local` | LocalizedDate | Localized date/time |

## Useful Template Expressions

```
# Short ID + subject + trailers
commit_id.short() ++ " " ++ description().lines().first() ++ " " ++ trailers().filter(|t| t.key == "type" || t.key == "scope").join(" ") ++ "\n"

# Human-readable date
date().local().short()

# Author name
author().name()

# All trailers as key=value pairs
trailers().map(|t| t.key ++ ": " ++ t.value).join(" ")
```
