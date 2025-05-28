function glb --description 'Git Log for reBase; calls `gl` without color or decorations, for use inside vim when editing the rebase todo' --argument count
    if test -n "$count"
        set argv $argv[2..]
        gl $count $argv
    else
        gl
    end
end
