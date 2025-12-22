function checksumdir --description 'Deterministically creates a single md5 hash for a directory of files, taking into account only file contents and not file names.' --argument-names dir
    # This is a fish port of the Python checksumdir package:
    # https://github.com/idahogray/checksumdir
    printf '%s' (find "$dir" -type f | sort | xargs -n 1 md5 -q | sort) | md5
end
