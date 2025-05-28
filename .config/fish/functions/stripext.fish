# Source: https://stackoverflow.com/a/53233847
function stripext --description "Strip file extension"
    for arg in $argv
        echo (dirname $arg)/(string replace -r '\.[^\.]+$' '' (basename $arg))
    end
end
