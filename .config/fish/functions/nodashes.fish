function nodashes --description 'Finds em dashes in the given files and replaces them with en dashes. With --stdin, reads replacement text from stdin.'
    argparse 'h/help' 'S/stdin' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: nodashes [--stdin] [path]"
        echo ""
        echo "Finds em dashes (—) in files and replaces them with en dashes (–)."
        echo ""
        echo "Modes:"
        echo ""
        echo "  nodashes <path>           Search and replace in the given file or directory."
        echo "  fd *.fish | nodashes      Pipe a list of files (one per line) to search and replace."
        echo "  echo \"text\" | nodashes -S   Use piped stdin as the replacement text instead of en dashes."
        echo ""
        echo "Options:"
        echo "  -S, --stdin    Read replacement text from stdin instead of replacing with en dashes."
        echo "  -h, --help     Show this help message."
        return 0
    end

    set emdashChar "—"
    set enDashChar "–"

    if set -q argv[1]
        and test -n "$argv[1]"
        scooter \
            --fixed-strings \
            --hidden \
            --immediate-search \
            --search-text $emdashChar \
            --replace-text $enDashChar \
            --files-to-include $argv[1]
    else if not test -t 0
        if set -q _flag_stdin
            read -lz text
            if test -z "$text"
                echo "No input on stdin" >&2
                return 1
            end
            scooter \
                --no-tui \
                --fixed-strings \
                --search-text $emdashChar \
                --replace-text $text
        else
            read -a -l -z files
            if test -z "$files"
                echo "No files on stdin" >&2
                return 1
            end
            scooter \
                --no-tui \
                --no-stdin \
                --fixed-strings \
                --hidden \
                --search-text $emdashChar \
                --replace-text $enDashChar \
                --files-to-include (string join "," $files)
        end
    end
end

