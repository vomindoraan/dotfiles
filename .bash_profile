# Usually appended to local .bashrc

# Source dotfiles
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

# 3-normal, 9-bright | 1-red, 2-green, 3-yellow, 4-blue, 5-magenta, 6-cyan
export PS1_HOSTCOLOR='32'

# Direnv
# eval "$(direnv hook bash)"

# VcXsrv interface
# export DISPLAY="$(ip route list default | grep -Eo '([0-9]+\.?){4}'):0"
# export LIBGL_ALWAYS_INDIRECT=1

# QMK
# source ~/qmk_utils/activate_wsl.sh
# export QMK_HOME=~/Projects/qmk_firmware

# If not in .bashrc, source it now
# [[ -f ~/.bashrc ]] && . ~/.bashrc
