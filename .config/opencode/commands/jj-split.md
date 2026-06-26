---
title: JJ Split Task
read_only: true
type: command
description: Split the current jj changeset into smaller, logical commits
agent: build
---
Use the `jj-split` skill to split the current Jujutsu changeset into smaller, logically separate commits.

Current working-copy state:
!`jj status`

Files changed in @:
!`jj diff --stat -r @`

Additional instructions (grouping hints, target revision, etc.): $ARGUMENTS
