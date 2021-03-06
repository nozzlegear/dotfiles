#! /usr/bin/env pwsh

git config --global --add alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit --all"
git config --global --add alias.last "log --decorate --pretty=oneline --abbrev-commit -3"
git config --global user.email "joshua@nozzlegear.com"
git config --global user.name "Joshua Harms"
git config --global core.ignorecase false  
# Configure line endings for windows 
git config --global core.autocrlf true
