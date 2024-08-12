function sdrg --description 'Searches and replaces text using ripgrep'
    function print_usage
        set -l green (set_color green)
        set -l normal (set_color normal)

        echo $green"USAGE:"$normal
        echo "  sdrg [options] <find> <replace_with> [<search_path> ...]"
    end

    function print_error
        set -l red (set_color red)
        set -l green (set_color green)
        set -l normal (set_color normal)

        echo "$red""error""$normal"": The following required arguments were not provided:"
        for arg in $argv
            echo "  $red<$arg>$normal"
        end
        echo ""
        print_usage
        echo ""
        echo "For more information try ""$green""--help""$normal"
    end

    function print_help
        set -l yellow (set_color yellow)
        set -l normal (set_color normal)
        
        print_usage
        echo ""
        echo "Options:"
        echo "$yellow -i, --interactive $normal"
        echo "    Interactively choose which matches should be replaced and which should be ignored."
        echo "$yellow -d, --dry-run $normal"
        echo "    Test the string replacements but do not save them. Changes will be written to the terminal as a git patch instead."
        echo "$yellow -h, --help $normal"
        echo "    Show this help message."
        echo ""
        echo "Examples:"
        echo "    # Find and replace strings in the current directory"
        echo "$yellow    sdrg 'find_string' 'replace_string' $normal"
        echo ""
        echo "    # Interactively find and replace strings in the current directory"
        echo "$yellow    sdrg -i 'find_string' 'replace_string' $normal"
        echo ""
        echo "    # Dry run for finding and replacing strings in the current directory"
        echo "$yellow    sdrg -d 'find_string' 'replace_string' $normal"
        echo ""
        echo "    # Find and replace strings in a specific directory"
        echo "$yellow    sdrg 'find_string' 'replace_string' /path/to/directory $normal"
    end

    argparse \
        'i/interactive' \
        'd/dry-run' \
        'h/help' \
        -- $argv
    or begin
        print_help
        return $STATUS
    end

    if set -q _flag_help
        print_help
        return 0
    end 

    # Check for <find> and <replace_with>
    begin
        set -l missingArgs

        if ! set -q argv[1]
            set -a missingArgs "find"
        end

        if ! set -q argv[2]
            set -a missingArgs "replace_with"
        end

        if test -n "$missingArgs"
            print_error $missingArgs
            return 1
        end
    end


    set -l searchStr $argv[1]
    set -l replaceStr $argv[2]

    # Erase the first and second arguments from argv. 
    set -e argv[1]
    # argv[1] again because list indexes shift down
    set -e argv[1] 

    # Now any remaining arguments in argv, if they exist, are assumend to be a list of paths or files that should be searched
    set -l searchTargets $argv
    set -l files (rg -lP "$searchStr" $searchTargets)

    echo "Searching for string \"$searchStr\" and replacing with \"$replaceStr\""
    echo "Files found matching strings:"

    for file in $files
        echo $file
    end

    set -l "perlCommand" 's/'$searchStr'/'$replaceStr'/g'

    if set -q _flag_dry-run
        echo "$perlCommand"
    end

    for file in $files
        if set -q _flag_dry-run
            perl -pe "$perlCommand" $file
        else
            # -i edits the files in place
            perl -i -pe "$perlCommand" $file
        end
    end
end
