function fixup
    set -l commit_id $argv[1]

    if test -z "$commit_id"
        set -l commits (git log @{u}..HEAD --oneline 2>/dev/null; \
                       or git log main..HEAD --oneline 2>/dev/null; \
                       or git log master..HEAD --oneline 2>/dev/null)

        set commit_id (printf '%s\n' $commits | sk --ansi | string split ' ' -f 1)
    end

    if test -n "$commit_id"
        git commit --fixup=$commit_id
    end
end
