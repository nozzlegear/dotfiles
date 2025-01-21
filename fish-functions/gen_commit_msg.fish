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

    set prompt "I want you to act as a commit message generator. I will provide you with a git diff containing changes I've made to my project, and I would like you to generate 3 appropriate commit messages using the conventional commit format. Do not give me choices like \"if the commit was adding a feature, choose this commit message,\" or \"if the commit was fixing a bug, choose that commit message;\" just do your best to decide which 3 commit messages are the most appropriate based on the changes contained in the git diff. Do not write any explanations or other words, just reply with the commit message. Here is the git diff: \n"
    set codeblocked_git_diff "```"(printf $input)"```"

    ask phi4 (printf "$prompt $codeblocked_git_diff")
end
