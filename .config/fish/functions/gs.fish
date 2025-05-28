function gs --wraps='git switch' --description 'alias gs git switch'
    if set -q argv[1]
        git switch $argv
    else
        git switch -
    end
end
