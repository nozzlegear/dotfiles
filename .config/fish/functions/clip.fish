function clip --wraps=pbcopy --description 'Copies the text or file to the clipboard using pbcopy'
    if not isatty stdin
        # Function has been piped to, assume text
        pbcopy $argv
    else
        set full_path (path resolve "$argv[1]")
        if ! test -e
            set_color red
            echo "File does not exist: $full_path"
            return 1
        else
            osascript -e "tell app \"Finder\" to set the clipboard to ( POSIX file \"$full_path\" )"
        end
    end
end
