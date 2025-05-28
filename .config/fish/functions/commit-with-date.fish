function commit-with-date -a dt -a msg
    set -x GIT_COMMITTER_DATE "$dt"
    # Drop the first two args from argv so they aren't duplicated
    set argv $argv[3..]

    git commit --date "$dt" -m "$msg" $argv
    set -e GIT_COMMITTER_DATE
end
