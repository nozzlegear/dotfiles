---
title: JJ Describe Task
read_only: true
type: command
description: Analyze the changes in the current changeset and give it a clear, concise description with type and scope trailers.
agent: build, commit
---
Use the `jj-describe` skill to analyze the changes in the current changeset (`@`) and write a clear, concise description with type and scope trailers.

Current changeset state:
!`jj status --no-pager`

Files changed in @:
!`jj diff --stat --no-pager -r @`

Additional instructions (purpose of the changes, wording to use, etc.): $ARGUMENTS
