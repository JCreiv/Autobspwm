# Setup fzf
# ---------
if [[ ! "$PATH" == */home/javi/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/javi/.fzf/bin"
fi

source <(fzf --zsh)
