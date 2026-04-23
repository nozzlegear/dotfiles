function s --wraps='git status --short' --wraps='jj status; or git status --short' --description 'alias s git status --short'
    if type -q jj
        set --local jj_root (jj root 2>/dev/null)
        if test -n "$jj_root"
            jj status
            return
        end
    end
    git status --short $argv
end
