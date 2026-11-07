---
title: JJ Describe Multi Task
read_only: true
type: command
---

Iterate through multiple `jj` changesets (aka "commits") and generate well-structured descriptions for each. Use the [jj-describe skill](skill://jj-describe) to analyze the changes in the user's desired changeset range, then write a clear, concise description with type and scope trailers for each jj changeset. Use the [jj-log skill](skill://jj-log) to read the jj changeset log.

Instructions (jj changeset range, purpose of the changes, wording to use, etc.): $ARGUMENTS

After you've described a changeset, you can read the description back to confirm that it was applied with this command:

`jj log -G -r $changeset_id -T 'description'`

> ![IMPORTANT]
> You **must** use the jj changeset id to reference , not the commit id. Commit ids are ephemeral in jj and will change after each operation, whereas changeset ids are stable. Furthermore, using commit ids can cause the stack to diverge, which is *not* what the user wants.

> ![NOTE]
> You need to read the skill named "jj-describe" ("skill://jj-describe"), then follow its instructions. To execute jj commands, you must use the bash tool – there is no jj tool, only the jj cli which must be executed via bash.

## Steps

1. Run `jj log --no-pager -G -r '$changeset_range'` to list commits in the user's desired range.
2. For each commit (starting from the oldest and walking forward):
   a. Run `jj diff --stat --no-pager -r $changeset_id` to see files changed
   b. Review the diff with `jj diff --no-pager -r $changeset_id` if needed
   c. Apply the instructions from the [jj-describe skill](skill://jj-describe) to analyze the type of changes and describe the changeset. Note: using `jj describe` will cause commits further up the stack to rebase. This is expected and normal jj behavior.
   d. Use `jj log -G -r $changeset_id -T 'description'` to read the description back and confirm that it was applied.
3. Continue sequentially until all commits in the range are described
