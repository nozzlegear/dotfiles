function hex -d "Converts an ASCII value to hexadecimal using the xxd command."
    function error
        set_color red
        echo $argv
        set_color normal
    end

    function print_usage
        set_color yellow
        echo ""
        echo "Usage:"
        echo '  hex $value'
        echo '  # or you can pipe the value into the function'
        echo '  echo "hello world" | hex'
        set_color normal
    end

    if set -q argv[1]
        switch $argv[1]
            case "--help" "-h"
                print_usage
                return 0
            case "*"
                set argInput $argv
        end
    end

    if not isatty stdin
        # Function may have been piped to, try to read stdin
        read -z pipeInput
    end

    if test -n "$argInput" -a -n "$pipeInput"
        error "Both a piped value and an input value were passed to this function, but only one value can be accepted."
        print_usage
        return 1
    else if test -n "$argInput"
        set input $argInput
    else if test -n "$pipeInput"
        set input "$pipeInput"
    else
        error "No input data provided."
        print_usage
        return 1
    end

    echo -n $input | xxd -p
end
