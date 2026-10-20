---
name: jj-hunk-split-driver
description: "Use when driving jj split -i non-interactively (hunk-level or partial-file splits) from a script, tool, or agent, or when reasoning about which commit jj's diff editor selects."
---

# Driving `jj split -i` without a TUI

Use when a program (agent tool, script) must split *part of a file's diff*, which fileset-based
`jj split <paths>` cannot do. Verified against jj 0.45.1.

## 1. Inject your own diff editor per invocation

Do not touch `~/.config/jj`. `--config` outranks user config and `--tool`/list-form implies `-i`:

```sh
jj --config ui.color=never --config ui.paginate=never \
   --config 'ui.diff-editor=["node","/abs/path/editor.js","/abs/spec.json","$left","$right"]' \
   split -i --message="selected changes" -r @
```

Facts:
- Array form resolves to `ExternalMergeTool` with `edit_invocation_mode: Dir`: **one** invocation, `$left`/`$right` are **directories**.
- `left` is read-only (parent state), `right` is writable (target state) and holds a `JJ-INSTRUCTIONS` file. Only changed paths are checked out; `JJ-INSTRUCTIONS` is ignored by the snapshot.
- The helper's cwd is the repo, not the temp dir: use absolute paths.
- A non-zero helper exit aborts the split (nothing is mutated).
- `--message=MSG` is accepted (attached form survives messages starting with `-`) and suppresses any editor.

## 2. Semantics that decide your implementation

- The **selected** commit's tree is the post-run snapshot of `right`. So selecting hunks means
  rewriting `right` into "parent content + selected changes": for every unselected hunk, emit its
  left variant (hunk lines minus `+` lines) at `newStart-1` (or 0 when `newStart == 0`).
- Unselect an **added** file by `unlink`ing it in `right`; unselect a **deletion** by copying
  `left/<p>` bytes into `right/<p>`; keep an added binary/empty file by leaving `right` alone.
- `-r @` topology: the selected commit **keeps the original change id** at its original position;
  the remainder is a **new child** with the full original target tree. Therefore `@-` = selection,
  `@` = remainder — and the working copy's *files do not change*. The remainder's changes are only
  visible as `jj diff -r @` (a diff against `@-`), never as rewritten file contents.
- Preserve trailing-newline state: a hunk line's terminator is `""` iff the next line is
  `\ No newline at end of file`.
- Refuse partial selection for rename/copy/mode-only/symlink/submodule entries. Renames are
  detectable only if jj emits them (not by default in 0.45); leaving a rename unselected would
  silently delete the old path in the selected commit.

## 3. Parse `jj diff --git` strictly

Pin `--config diff.git.show-path-prefix=true` so paths always carry `a/`/`b/`. Shapes that matter:
empty context lines are `" "` (a space, never a bare empty line); mode-only entries have no `index`
line (take the path from the `diff --git` line); a header-only empty added file has no `---`/`+++`
and no hunk; binaries emit `Binary files ... differ` with no hunks; `@@ -a,b +c,d @@` counts can be
omitted (means 1) and may carry a git-style trailing section heading. Verify the hunk body's line
counts against the header and throw on mismatch, and cross-check the parsed path list against
`jj diff --name-only -r REV`.

## 4. Verify

- Byte-compare `jj file show -r @- <path>` against the expected selected content.
- Compare `jj diff --git -r @-` (strip `index ...` lines, they are blob hashes) to the expected
  selected diff, and `jj diff --name-only -r @` to the expected remainder paths.
- Assert `jj log -r @- -T change_id` equals the pre-split `@` change id and that `all()` grew by
  exactly one commit.
- Every error path must throw before invoking `jj split`, so nothing is mutated; `jj undo` reverses
  a bad split otherwise.
