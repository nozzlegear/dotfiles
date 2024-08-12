function ctag -a "tagValue" -d "Commits and tags the current directory"
    if test -z "$tagValue"
        set_color yellow
        echo "No tag value specified. Usage: `ctag 1.2.3`"
        set_color normal
        return 1
    end

    # Ensure there are files staged for commit
    # Source: https://stackoverflow.com/a/3162492
    set -l count (git diff --cached --numstat | wc -l)

    if test "$count" -lt 1
        set_color yellow
        echo "No files are staged for commit. Either stage files to commit, or use the `tag` function to skip committing and only tag the last commit."
        set_color normal
        return 1
    end

    git commit -m "$tagValue";
    and tag "$tagValue";
end
