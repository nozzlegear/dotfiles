function glo -a limit
    if test -n "$limit"
        set limit "-n=$limit"
        set argv $argv[2..]
    else
        set -e limit
    end

    # Check if we're in a jj repo
    if type -q jj
        set --local jj_root (jj root 2>/dev/null)
        if test -n "$jj_root"
            jj log -r 'stack()' $limit $argv
            return
        end
    end

    git log $limit --color --graph --abbrev-commit --decorate --date=relative --date-order --format=format:'%C(yellow)%h%C(reset) %C(green)[%ar]%C(bold yellow)%d%C(reset)%C(reset) %s%C(reset) — %C(bold blue)%an%C(reset)' $argv
end
