---
name: jj-split
description: Split the current Jujutsu (jj) changeset into smaller, logically separate commits using non-interactive `jj split` with filesets. Use when the user asks to break up a change, split the working copy, separate unrelated edits into their own commits, stack a messy change into clean commits, or otherwise reshape one jj revision into several. Covers jj >= 0.42 topology, working-copy placement, and verification.
---

# Splitting a jj changeset into logical commits

`jj split` divides one revision into two. Repeating it peels a single change apart into a clean stack. This skill is for doing that **non-interactively** — no diff-editor TUI — because that is the only mode an agent can drive reliably.

## Mental model (jj >= 0.42)

`jj split [FILESETS]` on a target revision (default `@`):

- Files matching the filesets go into the **selected** commit. The selected commit **keeps the original change ID** and becomes the **parent**.
- Everything else goes into a **new child** commit (the **remaining** commit).
- When the target is `@`, the working copy moves to the **remaining** commit. After the split: `@-` holds the selected files, `@` holds the rest.
- Descendants of the target rebase onto the remaining commit automatically.

So named filesets land **earlier** in history (`@-`); the unnamed remainder stays at the tip (`@`). Build a stack by peeling the earliest logical commit first.

```
before                 jj split -m "auth" src/auth.rs

A                      A
|                      |
@  {auth, ui, docs}    o  auth        <- @-  (selected, named files, original change-id)
                       |
                       @  {ui, docs}  <- @   (remaining, working copy)
```

## Non-interactive invocation rules

- **Always pass filesets.** With no filesets, `jj split` opens an interactive diff editor and will hang an agent. Filesets disable interactive mode.
- **Always pass `-m`.** `-m "<msg>"` sets the description of the selected commit and suppresses the editor. The remaining commit keeps the original revision's description (or stays empty).
- Quote glob/fileset expressions so the shell does not expand them: `jj split -m "msg" 'glob:"src/**/*.fs"'`. Plain literal paths can be passed unquoted.
- Filesets are **file-granular**. They cannot select part of a file's diff. If a logical commit needs only some hunks of a file, this skill cannot do it — see "When to stop and ask".

## Workflow

1. **Inspect the change.**
   - `jj status` — see the target and changed paths.
   - `jj diff --stat -r @` — file-level overview.
   - `jj show -r @` or `jj diff -r @` when grouping decisions need the actual content.

2. **Group files into logical commits**, ordered from the one that should sit **earliest** in history to the last.

3. **Peel every group except the last.** For each group, run one split that names that group's files:

   ```
   jj split -m "Add Shopify fulfillment service client" src/Fulfillment/Service.fs src/Fulfillment/Service.fsi
   jj split -m "Wire fulfillment endpoints into router" src/Router.fs
   ```

   Each command pulls the named files into a new `@-` commit and leaves the rest in `@`. Run them against `@` in order; the target stays `@` between splits.

4. **Describe the final group.** After the last peel, `@` holds the remainder. Give it its message:

   ```
   jj describe -m "Update fulfillment integration tests"
   ```

   Note: `@` may have inherited the *original* changeset's description. Overwrite it deliberately with `jj describe -m` rather than leaving it.

5. **Verify.** Never assume placement — confirm it:
   - `jj log` — check the stack shape, order, and where `@` landed.
   - `jj show <change-id>` per commit — confirm each holds the intended files and nothing leaked.
   - A commit you did not intend to be empty showing `(empty)` means a fileset matched nothing or matched everything; fix and retry.

## Useful variants

- **Split a revision other than the working copy:** `jj split -r <rev> -m "msg" <files...>`. Selected stays at `<rev>` (original change-id), remainder becomes its new child, descendants rebase. `@` is untouched unless `@` was the target.
- **Parallel split (siblings, not a stack):** add `-p`/`--parallel` when the two parts are independent and should not be parent/child.
- **Place the selected commit elsewhere:** `-A <rev>` (insert after), `-B <rev>` (insert before), `-o <rev>` (rebase selected onto). The remaining changes stay in place. Use only when the user wants the extracted commit relocated, not stacked in place.

## Constraints and gotchas

- `jj split` **refuses to split an empty commit** — use `jj new` instead if that is the actual intent.
- Do **not** split immutable or already-pushed commits. jj blocks this; do not reach for `--ignore-immutable` without explicit user confirmation.
- A bookmark pointing at the split commit may move to one of the two parts. After splitting a bookmarked revision, check `jj log` and reposition with `jj bookmark move <name> --to <rev>` if it landed wrong.
- Untracked/new files are already part of `@` (jj auto-snapshots them); reference them by path in a fileset like any other file.
- Wrong split? `jj undo` reverses the last operation. It is cheap — prefer undo-and-retry over manual cleanup.
- If changes belong in an **existing ancestor commit** rather than a new one, `jj absorb` is the better tool than `split`.

## When to stop and ask

- A logical commit requires only **part of a single file's** changes. Filesets are file-level; this needs the interactive diff editor (`jj split -i`), which is a human task. Surface the file, explain the limitation, and let the user split that file by hand.
- The grouping is ambiguous and the files don't map cleanly to intents. Propose a grouping from `jj diff --stat` and confirm before rewriting history.
