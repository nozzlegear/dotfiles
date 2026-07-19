function openrouter --description 'Adds $OPENROUTER_API_KEY to the shell process'
    if not status is-command-substitution
        or test (status current-command) != "fish"
        # These variables may already be set by the parent shell, so check if they
        # need to be unlocked first
        if not set -q OPENROUTER_API_KEY
            set -x OPENROUTER_TOKEN (security find-generic-password -a "openrouter" -s "Openrouter API key" -w)
        end
    end
end
