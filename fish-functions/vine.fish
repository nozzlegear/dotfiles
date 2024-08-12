function vine
    function print_help
        set_color yellow
        echo "Usage:"
        set_color normal
        echo "  vine [--keep-temp] --name output_file_without_extension https://youtube.com/example"
    end

    function print_error -a msg
        echo "vine: $msg"
        echo ""
    end

    argparse --name=vine 'h/help' 'k/keep-temp' 'n/name=' -- $argv
    or begin
        echo ""
        print_help
        return 1
    end

    if set -q _flag_help
        print_help
        return 0
    end

    if ! set -q _flag_name
        print_error "--name: value is required"
        print_help
        return 1
    else if test -z "$_flag_name"
        print_help
        print_error "--name: value cannot be empty"
        return 1
    end

    if ! set -q argv[1]
        print_error "video url value is required"
        print_help
        return 1
    end

    set url $argv[1]
    set name $_flag_name
    set extension "mov"
    set temp_filename "$name.$extension"
    set final_filename "$name.$extension"
    set final_folder "$HOME/Movies/vines"

    set temp_folder (mktemp -d "/tmp/vine.XXXXXXXX")
    cd "$temp_folder"
    or return 1

    # Use yt-dlp to download the video and capture the output
    set filename (yt-dlp --quiet --no-simulate --print "_filename" -o "$name.%(ext)s" "$url")
    or return 1

    if set -q _flag_keep_temp
        set_color yellow
        echo "Keeping temporary file $temp_folder/$filename"
        set_color normal
    end

    if test (path extension "$filename") != ".$extension"
        ffmpeg -loglevel warning -i "$filename" "$temp_filename"
        or return 1
    end

    cd "$final_folder"
    or return 1

    while test -e "$final_filename"
        if ! set -q total
            set total 1
        else if test $total -gt 20
            # Stop any loops from getting out of hand
            set_color red
            echo "error: could not find a suitable filename after $total tries."
            return 1
        else
            set total (math "$total + 1")
        end
        set_color yellow
        echo "$final_filename already exists in $final_folder, incrementing filename."
        set_color normal
        set final_filename "$name""_$total.$extension"
    end

    mv "$temp_folder/$temp_filename" "$final_filename"
    or return 1

    if ! set -q _flag_keep_temp
        rm -r "$temp_folder"
    end

    set_color green
    echo "$final_filename has been downloaded to $final_folder"
end
