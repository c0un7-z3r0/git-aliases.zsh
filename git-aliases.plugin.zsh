pull_or_push() {
    if [ $# -eq 2 ]; then
        git $1 $2 `git rev-parse --abbrev-ref HEAD`
    else
        git $1 origin `git rev-parse --abbrev-ref HEAD`
    fi
}
pull() { pull_or_push "pull" $@ }
push() { pull_or_push "push" $@ }

alias gf='git fetch'
alias gb='git branch'
alias unmerged="git branch --no-merged"
alias plog="git log --oneline --decorate"

reset() {
    if [ $# -eq 0 ]; then
        git reset --hard
    else
        local curr_branch=`git rev-parse --abbrev-ref HEAD`
        git checkout $curr_branch $1
    fi
}

flog() {
    git log -p $1
}

status() {
    if [ "$GIT_ALIASES_SHORTER_GIT_STATUS" -ne 1 ]; then; git status
else; git status -sb; fi
}
alias s='status'

co() {
    git fetch
    git checkout "$1"
    if [ "$GIT_ALIASES_SILENCE_GIT_STATUS" -ne 1 ]; then; git status; fi
}
compdef _git co=git-checkout

cob() {
    git checkout -b "$1"
    if [ "$GIT_ALIASES_AUTOPUSH_NEW_BRANCH" -eq 1 ]; then
        git add "$(git rev-parse --show-toplevel)" && git commit -a -m "Started $1" && push
    fi
}

cobm() {
    git checkout master && pull && git checkout -b "$1"
}

cobd() {
    git checkout develop && pull && git checkout -b "$1"
}

corbm() {
    corp master && git checkout -b "$1"
}

corbd() {
    corp develop && git checkout -b "$1"
}

cop() {
    git fetch && git checkout "$1" && pull && git fetch
    if [ "$GIT_ALIASES_SILENCE_GIT_STATUS" -ne 1 ]; then; git status; fi
}
compdef _git cop=git-checkout


yp() {
    pull && git fetch && yarn
}

coyp() {
    co "$1" && yp
}
compdef _git corp=git-checkout

backmerge_branch() {
    local curr_branch=`git rev-parse --abbrev-ref HEAD`
    pull && cop $1 && co $curr_branch && git merge $1 -m 'Backmerged master' && push
    echo 'Backmerge completed.'
}

grmb() {
    git_rm_merged
}

git_rm_merged() {
    git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -d
}