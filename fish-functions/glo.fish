function glo
    if test -n "$count"
        set count "-n $count"
        set argv $argv[2..]
    else
        set -e count
    end

    git log $count --color --graph --abbrev-commit --decorate --date=relative --date-order --format=format:'%C(yellow)%h%C(reset) %C(green)[%ar]%C(bold yellow)%d%C(reset)%C(reset) %s%C(reset) — %C(bold blue)%an%C(reset)' $argv
end
