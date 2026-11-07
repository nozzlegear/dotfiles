---
title: split
read_only: true
type: command
description: Split the current jj changeset into smaller, logical commits
---
Use skill://jj-split and skill://jj-hunk-split-driver to split the current jj changeset (`@`) into smaller, more focused commits.

Files changed in `@`:
!`jj diff --summary -r @ --no-pager`

Current jj stack:
!`jj log -r 'stack(@,1)' --no-pager`

Additional instructions (grouping hints, target revision, etc.): $ARGUMENTS
