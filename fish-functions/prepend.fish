set scriptName "prepend"

function prepend -d "Prepends text to the given file."

    function print_help -a err
        if test "$err" = "argparse"
            echo ""
        else if test -n "$err"
            set_color red
            echo "$scriptName: $err"
            echo ""
        end

        set_color yellow
        echo "USAGE:"
        echo ""
        echo "  $scriptName "
        echo "      -f/--file path_to_file"
        echo "      \"text to prepend to file\""
    end

    set_color red
    argparse --name="$scriptName" 'h/help' 'f/file=' -- $argv;
    or begin
        print_help "argparse"
        return 1
    end
    set_color normal

    if test "$_flag_help"
        print_help
        return 1
    end

    if test -z "$_flag_file"
        print_help "Missing file path."
        return 1
    end

    if test -z "$argv"
        print_help "Text is empty, refusing to prepend."
        return 1
    end

    if ! test -f "$_flag_file"
        touch "$_flag_file"
    end

    # Concatenate the new text and the file text together
    # Source: https://superuser.com/a/246841
    echo "$argv" | cat - "$_flag_file" > /tmp/prepend.txt; and mv /tmp/prepend.txt "$_flag_file"
end
