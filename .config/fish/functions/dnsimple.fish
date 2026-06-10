function dnsimple --wraps=/opt/homebrew/bin/dnsimple
    # is-command-substitution is true for both tab completion and scripted
    # substitution (i.e. things like `set foo (dnsimple domains list)` or
    # `echo "domains is " (dnsimple domain get xyz.com)`
    #
    # The `status current-command` is equal to "fish" only during tab
    # completion (Fish seems to evaluates them internally), so we can
    # reliably assume that `if (status current-command) = "fish"` then we're
    # doing tab completions.
    #
    # We skip the keychain unlock only when it's a substitution AND current-command is fish.
    if not status is-command-substitution
        or test (status current-command) != "fish"
        # These variables may already be set by the parent shell, so check if they
        # need to be unlocked first
        if not set -q DNSIMPLE_TOKEN
            set -x DNSIMPLE_TOKEN (security find-generic-password -a "dnsimple" -s "cli-token" -w)
        end
        if not set -q DNSIMPLE_ACCOUNT
            set -x DNSIMPLE_ACCOUNT (security find-generic-password -a "dnsimple" -s "account-id" -w)
        end
    end

    /opt/homebrew/bin/dnsimple $argv
end
