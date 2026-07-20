---
title: JJ Describe Task
read_only: true
type: command
description: Analyze the changes in the current changeset and give it a clear, concise description with type and scope trailers.
agent: build, commit
---
Use the [jj-describe skill](skill://jj-describe) to analyze the changes in the current changeset (`@`) and write a clear, concise description with type and scope trailers.

Current changeset state:
!`jj status --no-pager`

Files changed in @:
!`jj diff --stat --no-pager -r @`

Additional instructions (purpose of the changes, wording to use, etc.): $ARGUMENTS

> ![NOTE]
> You need to read the skill named "jj-describe" ("skill://jj-describe"), then follow its instructions. To execute jj commands, you must use the bash tool – there is no jj tool, only the jj cli which must be executed via bash.
