function tag -a "tagValue" -d "Runs `git tag -s` on the current directory"
    if test -z "$tagValue"
        set_color yellow
        echo "No tag value specified. Usage: `tag 1.2.3`"
        set_color normal
        return 1
    end
    git tag -s "$tagValue" -m "$tagValue"
end
