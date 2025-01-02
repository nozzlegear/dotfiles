function journal
    if test "$argv[1]" = "init"
        set -f journal .journal.log
    else
        set -f journal ~/.journal.log
    end
    touch $journal

    set -l dirparts (string split "/" (pwd))
    set -l dircount (count $dirparts)
    for x in (seq $dircount -1 2)
       set -l dir (string join "/" $dirparts[1..$x])
       if test -f $dir/.journal.log
               set -f journal $dir/.journal.log
               break
       end
    end

    if test "$argv[1]" = "show"
       printf "Last journal entries from: %s\n" "$journal"
       tail -5 $journal
    else
       printf "Add to journal: %s\n" "$journal"
       read -P "Addition: " -l line
       if test -z "$line"
           printf "Nothing added.\n"
           return
       end
       printf "%s\n" "$line" >> "$journal"
    end
end
