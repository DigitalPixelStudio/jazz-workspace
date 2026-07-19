#!/bin/bash
# Jazz🔥 custom prompt with git status
parse_git_branch() {
    git branch 2>/dev/null | sed -n '/^\*/s/^\* //p'
}
git_status() {
    local branch=$(parse_git_branch)
    [ -n "$branch" ] && echo " 🔥($branch)"
}
PS1='\[\033[38;5;208m\]Jazz🔥\[\033[0m\] \[\033[38;5;39m\]\w\[\033[0m\]$(git_status)\n$ '
