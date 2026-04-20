function _pure_prompt_jj --description 'Print jj working copy information'
    # Bookmark name if present, short change ID otherwise
    # Appends * when working copy has file changes, ! when conflicted
    set --local jj_info (jj log -r @ --no-graph -T '
        coalesce(
            local_bookmarks.map(|b| b.name()).join(","),
            change_id.short(8)
        )
        ++ if(conflict, "!", "")
        ++ if(!empty, "*", "")
    ' 2>/dev/null | string trim)
    
    test -n "$jj_info" || return
    
    set --local color (_pure_set_color $pure_color_git_branch)
    echo "$color$jj_info"(set_color normal)
end
