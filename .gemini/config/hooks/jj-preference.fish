#!/usr/bin/env fish

# Example input, received via stdin
# source: https://antigravity.google/docs/hooks
#
# {
#   "toolCall": {
#     "name": "run_command",
#     "args": {
#       "CommandLine": "git status",
#       "Cwd": "/Users/nozzlegear/Repos/stages",
#       "WaitMsBeforeAsync": 5000
#     }
#   },
#   "stepIdx": 19,
#   "conversationId": "jj-preference-test",
#   "workspacePaths": ["/workspace/project"],
#   "transcriptPath": "~/.gemini/antigravity-cli/brain/jj-preference-test/.system_generated/logs/transcript.jsonl",
#   "artifactDirectoryPath": "~/.gemini/antigravity-cli/brain/jj-preference-test"
# }

# Example item from transcriptPath
# (no source, just pulled from ~/.gemini/antigravity-cli/brain/jj-preference-test/.system_generated/logs/transcript.jsonl)
#
#{
#  "step_index": 57,
#  "source": "MODEL",
#  "type": "PLANNER_RESPONSE",
#  "status": "DONE",
#  "created_at": "2026-06-21T20:15:14Z",
#  "content": "Let's check `git status` to see how Git is tracking the changes.",
#  "tool_calls": [
#    {
#      "name": "run_command",
#      "args": {
#        "CommandLine": "\"git status\"",
#        "Cwd": "\"/Users/nozzlegear/repos/wow-addons/djui-raid-profile-selector\"",
#        "WaitMsBeforeAsync": "5000",
#        "toolAction": "\"Run git status\"",
#        "toolSummary": "\"Run command\""
#      }
#    }
#  ]
#}

function resolveHomeDir -a pathName -d "Resolves the ~/ home directory with the \$HOME variable."
    path resolve (string replace -r '^~(?=/|$)' $HOME -- "$pathName")
end

set input (cat)
set transcriptPath (resolveHomeDir (echo $input | jq -r '.transcriptPath'))
set toolCallName (echo $input | jq -r '.toolCall.name')
set toolCallCommand (echo $input | jq -r '.toolCall.args.CommandLine')
set toolCallCwd (resolveHomeDir (echo $input | jq -r '.toolCall.args.Cwd // .workspacePaths[0]'))

# Only act on git commands
if not test "run_command" = "$toolCallName"
   or not string match -qr '^git(\s|$)' -- $toolCallCommand
    exit 0
end

# Check if the agent is using the tool in a jj repo
if jj root -R "$toolCallCwd" 2>/dev/null 1>/dev/null
    # Check if the toolCallCommand contains [NO_JJ] (e.g. appended as a comment like 'git command # [NO_JJ]')
    if string match -q "*[NO_JJ]*" -- $toolCallCommand
        set transcriptSetNoJJ true
    else
        # Check if the last PLANNER_RESPONSE item in the transcript contains [NO_JJ] in its toolSummary
        if not test -e "$transcriptPath"
            echo "Could not find conversation transcript file $transcriptPath to confirm whether [NO_JJ] was set in the tool summary."
            exit 1
        end

        # Use jq -s (--slurp) to slurp each jsonl line into an array
        cat $transcriptPath | jq -s -e 'map(select(.type == "PLANNER_RESPONSE"))[-1].tool_calls[]? | select(.args.toolSummary // "" | contains("[NO_JJ]"))' >/dev/null 2>&1

        if test $status -eq 0
            set transcriptSetNoJJ true
        else
            set transcriptSetNoJJ false
        end
    end

    if $transcriptSetNoJJ
        # Agent confirms that it wants to use git despite being in a jj repo
        set decision "allow"
        set reason "You attempted to use a git command in a jj repository, and have confirmed that git is appropriate by appending `# [NO_JJ]` to the shell command. Git usage is allowed."
        set permissionOverrides "command($toolCallCommand)"
    else
        # We can also use "ask" and "force_ask"
        set decision "deny"
        set reason "You attempted to use a git command, but this is a jj (Jujutsu) repository. The user strongly prefers that you use jj commands instead of git commands. You should retry with the appropriate jj command. If you see this message and determine that the git command is still more appropriate, modify the tool call by appending `# [NO_JJ]` to the shell command and then try again."
        set permissionOverrides ""
    end
else
    # We're not in a jj repo, agent can use git
    set decision "allow"
    set reason "This is not a jj repository, git commands are allowed."
    set permissionOverrides "command($toolCallCommand)"
end

if test "$permissionOverrides" = ""
    set permissionOverrides "[]"
else
    set permissionOverrides (jq -nrc --arg overrides "$permissionOverrides" '[$overrides]')
end

echo "overrides: $permissionOverrides" >&2

jq -n -r \
    --arg "decision" "$decision" \
    --arg "reason" "$reason" \
    --argjson "permissionOverrides" "$permissionOverrides" \
    '{$reason, $decision, $permissionOverrides}'

exit 0
