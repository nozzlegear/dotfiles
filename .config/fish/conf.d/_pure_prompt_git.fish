function _pure_prompt_git --description 'Print git/jj repository information'
    set ABORT_FEATURE 2

    if set --query pure_enable_git; and test "$pure_enable_git" != true
        return
    end

    if type -q jj
        set --local jj_root (jj root 2>/dev/null)
        if test -n "$jj_root"
            _pure_prompt_jj
            return
        end
    end

    if not type -q --no-functions git
        return $ABORT_FEATURE
    end

    set --local is_git_repository (command git rev-parse --is-inside-work-tree 2>/dev/null)

    if test -n "$is_git_repository"
        set --local git_prompt (_pure_prompt_git_branch)(_pure_prompt_git_dirty)(_pure_prompt_git_stash)
        set --local git_pending_commits (_pure_prompt_git_pending_commits)

        if test (_pure_string_width $git_pending_commits) -ne 0
            set --append git_prompt $git_pending_commits
        end

        echo $git_prompt
    end
end
