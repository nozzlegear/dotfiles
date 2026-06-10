#!/usr/bin/env fish

set INPUT (cat)
set COMMAND (echo $INPUT | jq -r '.tool_input.command // .arguments.CommandLine // .tool_input.CommandLine // ""')
set DESCRIPTION (echo $INPUT | jq -r '.tool_input.description // .arguments.toolAction // .arguments.toolSummary // .tool_input.toolAction // .tool_input.toolSummary // ""')

# Only act on git commands (belt-and-suspenders alongside the hook's filter)
if not string match -qr '^git(\s|$)' -- $COMMAND
    exit 0
end

# Check if we're in a jj repo
if jj root 2>/dev/null 1>/dev/null
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"This is a jj repository. You must use jj commands instead of git. Re-issue your command using the jj equivalent."}}'
    exit 0
end

# Not a jj repo — require [NO_JJ] in the description or command to confirm verification
if string match -qr '\[NO_JJ\]' -- $DESCRIPTION; or string match -qr '\[NO_JJ\]' -- $COMMAND
    exit 0
end

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"You attempted a git command. Please verify this repository is not using Jujutsu (jj). If .jj does NOT exist, retry the git command with [NO_JJ] added to your description/toolAction parameter to confirm your verification. If .jj DOES exist, use jj instead."}}'
exit 0
