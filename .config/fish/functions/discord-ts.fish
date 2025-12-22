function discord-ts --description "Converts a local clock time to Discord's unix timestamp"
    set -l prompt (printf "Local clock time:\n> ")
    read -P "$prompt" input
    if test -z "$input"
        set_color red
        echo "No input given"
        return 1
    end

    set today (gdate "+%Y-%m-%d")
    set ts (gdate -d "$today $input" '+%s')

    if test $status -ne 0
        set_color red
        echo "Could not parse: $input"
        return 1
    end

    echo "<t:$ts:t>"
end
