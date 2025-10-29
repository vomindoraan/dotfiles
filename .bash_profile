# Usually appended to local .bashrc

export DOT_DIR="/mnt/c/Users/konst/OneDrive/Documents/Config"
export DOT_BASHRC="$DOT_DIR/.bashrc"
export DOT_ALIASES="$DOT_DIR/.bash_aliases"
export DOT_COMPLETION="$DOT_DIR/.bash_completion"
export DOT_COMPLETION_PY="$DOT_DIR/bash_completion.py"
. "$DOT_BASHRC"
. "$DOT_ALIASES"
if find "$DOT_ALIASES" "$DOT_COMPLETION_PY" -newer "$DOT_COMPLETION" | read; then
    python "$DOT_COMPLETION_PY" > "$DOT_COMPLETION"
fi
. "$DOT_COMPLETION"

export PS1_HOSTCOLOR='32'  # 3-normal, 9-bright | 1-red, 2-green, 3-yellow, 4-blue, 5-magenta, 6-cyan

eval "$(direnv hook bash)"

# [[ -f ~/.bashrc ]] && . ~/.bashrc
