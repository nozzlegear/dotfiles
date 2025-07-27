function get-manifest-digest --description "Gets the image manifest's sha256 digest" --argument-names image_name
    set function_name (status current-command)

    function print_help -V function_name
        set_color yellow
        echo "USAGE:"
        echo "  $function_name <image_name>"
        set_color normal
    end

    if string match -q --regex -- "-h|--help" "$argv"
        print_help
        return 0
    end

    if test -z "$image_name"
        print_help
        set_color red
        echo "ERRORS:"
        echo "  <image_name> cannot be empty"
        return 1
    end

    set temp_file (mktemp)

    function __cleanup -V temp_file --on-event fish_exit
        rm $temp_file
    end

    skopeo inspect --raw "docker://$image_name" > "$temp_file"
    or return 1

    skopeo manifest-digest "$temp_file"
    or return 1
end
