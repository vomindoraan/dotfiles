# Shell config
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
bind '"\e[Z":menu-complete-backward'
bind 'TAB:menu-complete'
bind 'set bell-style none'
bind 'set completion-ignore-case on'
bind 'set menu-complete-display-prefix on'
bind 'set show-all-if-ambiguous on'
shopt -s checkwinsize
shopt -s extglob
shopt -s globstar
shopt -s nullglob
shopt -s no_empty_cmd_completion
stty -ixon -ixoff  # Enable Ctrl+s and Ctrl+q

# Environment config
export IGNOREEOF=1
export EDITOR='nvim -e'
export VISUAL='nvim'
export PAGER='less'

# Title:  <pwd>: <cmd>
# Prompt: <user>@<host> <pwd>[ <git>]
#         [<venv> ]$ 
# Colors: user/host: PS1_HOSTCOLOR, pwd: yellow, git: cyan, venv: red
#         3-normal, 9-bright | 1-red, 2-green, 3-yellow, 4-blue, 5-magenta, 6-cyan 
export PS1_HOSTCOLOR='32'
export PS1='\[\033]0;\W: $BASH_COMMAND\007\]
\[\033[${PS1_HOSTCOLOR}m\]\u@\h \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]
\[\033[31m\]`direnv_ps1``status_ps1`$\[\033[0m\] '
# export GIT_PS1_SHOWDIRTYSTATE=1  # May cause slowdown in large repos
export GIT_PS1_STATESEPARATOR=

# https://seasonofcode.com/posts/debug-trap-and-prompt_command-in-bash.html
pre_command() {
    if [[ -n "$AT_PROMPT" ]]; then
        unset AT_PROMPT
        eval "$PRE_CALLBACKS"
    fi
}
trap 'pre_command' DEBUG

FIRST_PROMPT=1
post_command() {
    CMD_STATUS=$?
    AT_PROMPT=1
    if [[ -n "$FIRST_PROMPT" ]]; then
        unset FIRST_PROMPT
    else
        eval "$POST_CALLBACKS"
    fi
}
PROMPT_COMMAND='post_command'

# Add a callback to be evaluated before each command
add_pre() {
    PRE_CALLBACKS+="$1;"
}

# Add a callback to be evaluated after each command
add_post() {
    POST_CALLBACKS+="$1;"
}

# Set title at start because of long, blocking commands like ssh
set_title() {
    local pwd="$(dirs +0)"
    echo -en "\033]0;${pwd##*/}: $BASH_COMMAND\007"
}
add_pre set_title

# If running in Windows Terminal, tell it what the PWD is
if [[ -n "$WT_SESSION" ]]; then
    wt_set_pwd() {
        printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"
    }
    add_post wt_set_pwd
fi

# Set prompt color depending on exit status of last command
# success: bright white, failure: gray
status_ps1() {
    [[ $CMD_STATUS == 0 ]] && echo -en "\033[1;37m" || echo -en "\033[1;30m"
}
export -f status_ps1

# Show direnv virtual env status in prompt
direnv_ps1() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename "$VIRTUAL_ENV")) "
  fi
}
export -f direnv_ps1

# Git config
git config --global column.ui auto
git config --global core.autocrlf input
git config --global core.editor $VISUAL
git config --global core.fsmonitor true
git config --global core.preloadindex true
git config --global core.safecrlf warn
git config --global diff.tool vimdiff
git config --global diff.wserrorhighlight all
git config --global init.defaultbranch master
git config --global log.decorate auto
git config --global log.follow true
git config --global merge.tool kdiff3
git config --global pull.rebase true
git config --global push.default current
git config --global push.autosetupremote true
git config --global rebase.autosquash true
git config --global rebase.autostash true
git config --global rerere.autoupdate true
git config --global rerere.enabled true
git config --global stash.showpatch true
git config --global stash.showstat false
git config --global status.branch true
git config --global status.short true

# Convenience functions
# Change directory to Windows-style path (usage: cdw WINPATH)
cdw() {
    cd "$(wslpath "$1")"
}

# Make directory(ies) and change to the first one (usage: mkcd DIR...)
mkcd() {
    mkdir "$@" && cd "$1"
}

# Run command with colored stderr output (usage: color CMD)
color() {
    (set -o pipefail; "$@" 2>&1>&3 | sed $'s/.*/\e[31m&\e[m/' >&2) 3>&1
}

# Time HTTP request (usage: curl_time [OPTION...] URL)
curl_time() {
    curl -so /dev/null -w "\
   namelookup:  %{time_namelookup}s\n\
      connect:  %{time_connect}s\n\
   appconnect:  %{time_appconnect}s\n\
  pretransfer:  %{time_pretransfer}s\n\
     redirect:  %{time_redirect}s\n\
starttransfer:  %{time_starttransfer}s\n\
-------------------------\n\
        total:  %{time_total}s\n" "$@"
}

# Run diff and pipe output into pager
diffp() {
    diff --color=always "$@" | $PAGER -RFX
}

# Run ripgrep and pipe output into pager
rgp() {
    rg -p "$@" | $PAGER -RFX
}

# Run ripgrep and count total number of matches
rgc() {
    rg --count-matches "$@" | awk -F: '{sum += $2} END {print sum}'
}

# Run ripgrep and open files with matches in editor
rgv() {
    rg "$@" -l0 | xargs -0 $VISUAL
}

# List file paths matching glob(s) using ripgrep (usage: rgfind GLOB...)
rgfind() {
    local args=();
    for glob in "$@"; do
        args+=(-g "$glob")
    done
    rg . -l "${args[@]}"
}

# Concurrently build all files matching glob(s) using GCC (usage: gcc_all GLOB...)
gcc_all() {
    for src in "$@"; do
        local out="$(basename "$src")"
        (gcc "$src" -o "${out%.*}" &)
    done
}

# Concurrently build all files matching glob(s) using MSVC (usage: cl_all GLOB...)
cl_all() {
    for src in "$@"; do
        (cl "$src" -link 2>/dev/null | grep -E 'warning|error' &)
    done
}

# Run pip command separately for each argument (usage: pip_each CMD [ARG...])
pip_each() {
    local cmd="$1"
    shift
    echo "$@" | xargs -tn 1 pip "$cmd"
}
