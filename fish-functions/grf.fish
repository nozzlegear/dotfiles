function grf --description 'alias grf git fzr'
  git diff --staged --name-only $argv | fzf -m --print0 | xargs -o -0 git reset
end
