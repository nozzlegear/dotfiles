function create-podman-secrets -d "Creates a series of podman secrets based on an env file."
    set ENV_FILE "$argv[1]"

    function error 
        set_color red
        echo "❌ $argv"
        set_color normal
    end

    if test -z "$ENV_FILE"
        error "No env file passed to script."
        set_color yellow
        echo ""
        echo "   Usage: ./script.fish path/to/env/file.env"
        return 1
    end

    if test -z "$ENV_FILE" -o ! -e "$ENV_FILE"
        error "Could not find file at \"$ENV_FILE\"."
        return 1
    end

    # Read the entries in the env file and split each line on either an equals (=) sign or a space.
    # Note that sed uses greedy matching, meaning it will match as many characters as possible if there are multiple matches.
    # That means any variable in the file containing what we want to match on can cause sed to match more than just the variable name.
    # To counteract that, reverse the lines so that the greedy matching works in our favor.
    set REGEX "\(.*\)[= ]\(.*\)"
    set EXISTING_SECRETS (podman secret ls --noheading --format "{{.Name}}")

    for LINE in (cat "$ENV_FILE")
        set KEY (echo "$LINE" | rev | sed -e "s/$REGEX/\2/" | rev)
        set VALUE (echo "$LINE" | rev | sed -e "s/$REGEX/\1/" | rev)

        if contains "$KEY" $EXISTING_SECRETS
            echo "🗑 Secret $KEY already exists, deleting it."
            podman secret rm "$KEY"
            or return 1
        end

        echo "✏️ Creating secret $KEY."
        # Note: newlines must be removed from the value. Podman will not remove them and thus they become part of the secret value.
        echo -n "$VALUE" | tr -d '\r\n' | podman secret create "$KEY" -
        or return 1
        echo ""
    end

    set_color green
    echo "✅ Done!"
end
