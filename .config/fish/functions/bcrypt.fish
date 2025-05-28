# Source: https://unix.stackexchange.com/a/419855
function bcrypt -d "Uses bcrypt to hash a string." -a value
    if test -z "$value"
        set_color yellow
        echo "Usage:"
        echo "  bcrypt \"password-or-string-here\""
        echo 
        set_color red
        echo "You must supply a string to hash."
        return 1
    end

    htpasswd -bnBC 10 "" "$value" | tr -d ':\n' | sed 's/$2y/$2a/'
end
