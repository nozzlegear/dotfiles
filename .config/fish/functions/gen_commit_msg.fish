function gen_commit_msg --argument gitDiff
    set script_name (status function)

    function print_help -a msg -V script_name
        if test -n "$msg"
            set_color red
            echo "$msg"
        end
        set_color yellow
        echo "Usage:"
        echo "  git diff --cached | $script_name"
        set_color grey
        echo "  # or"
        set_color yellow
        echo "  $script_name (git diff --cached)"
    end

    if not isatty stdin
        # Function has been piped to, try to read stdin
        read -z pipeInput
    end

    if test -n "$gitDiff" -a -n "$pipeInput"
        print_help "Both a piped value and a function arg were passed to this function, but only one can be accepted."
        return 1
    else if test -n "$gitDiff"
        set input $gitDiff
    else if test -n "$pipeInput"
        set input $pipeInput
    else
        print_help "No git diff or text was passed to this function."
        return 1
    end

    set codeblocked_git_diff (printf "```%s\n```Could you please generate 3 commit messages (preferably with a body going into more detail about the commit) for the git diff I've just given you?" $input)

    ollama run --nowordwrap commit-message-generator "$codeblocked_git_diff"
end
