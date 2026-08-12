function openrouter --description 'Adds $OPENROUTER_API_KEY to the shell process'
    if not status is-command-substitution
        or test (status current-command) != "fish"
        # These variables may already be set by the parent shell, so check if they
        # need to be unlocked first
        if not set -q OPENROUTER_API_KEY
            set -x OPENROUTER_API_KEY (security find-generic-password -a "openrouter" -s "Openrouter API key" -w)
        end

        # Only echo if this is command substitution (e.g. `set foo (openrouter)` or `curl -H "Authorization: $(openrouter)"`)
        if status is-command-substitution
            echo "$OPENROUTER_API_KEY"
        else
            set_color yellow
            echo 'Refusing to write key unless command substitution is used, e.g. `set foo (openrouter)` or `curl -H "Authorization: $(openrouter)"`'
        end
    end
end
