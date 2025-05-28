function gapf --description 'alias gapf git ls-files -m -o --exclude-standard | fzf -m --print0 | xargs -o -0 git add -p'
  git ls-files -m -o --exclude-standard $argv | fzf -m --print0 | xargs -o -0 git add -p
        
end
