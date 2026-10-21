function _pure_tmux_attached_via_ssh --description 'Whether the tmux client is running under sshd'
    set --local pid (tmux display-message -p '#{client_pid}' 2>/dev/null | string trim)
    test -n "$pid"; or return 1

    while true
        test -n "$pid"; and test "$pid" -gt 1; or return 1

        if ps -o command= -p $pid 2>/dev/null | string match -qr '(^|[ /])sshd( |:|$)'
            return 0
        end

        set pid (ps -o ppid= -p $pid 2>/dev/null | string trim)
    end
end

function _pure_prompt_ssh
    # SSH_CONNECTION in a tmux pane comes from the tmux session environment,
    # which keeps a stale value from whichever client created the session.
    # Only trust it when the attached client is actually running under sshd.
    test -n "$SSH_CONNECTION"; or return

    if set -q TMUX; and not _pure_tmux_attached_via_ssh
        return
    end

    echo "$pure_symbol_ssh_prefix"(_pure_user_at_host)
end
