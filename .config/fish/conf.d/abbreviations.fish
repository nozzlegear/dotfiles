abbr -a -- size 'du -hs'
abbr -a -- du 'dust -rd1'
abbr -a --set-cursor='%' -- audio 'yt --extract-audio --audio-format wav "%"'
abbr -a -- video 'yt-dlp --format best'
abbr -a -- find 'fd --full-path --hidden --ignore-case'
abbr -a -- sedr 'sd --preview'
abbr -a -- tree 'eza --git-ignore --tree --level=5'
abbr -a -- fe 'fd --full-path --hidden --ignore-case --extension'
abbr -a -- amend 'git commit --amend'
abbr -a --set-cursor='%' -- commit 'git commit --edit -m "%"'
abbr -a -- rebase 'git rebase --interactive --autosquash'
abbr -a -- con 'git rebase --continue'

if test (uname -s) = "Darwin"
    abbr i brew install
else
    abbr i sudo apt install -y
end

