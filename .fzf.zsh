# Setup fzf
# ---------
if [[ ! "$PATH" == */home/$USER/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/$USER/.fzf/bin"
fi

source <(fzf --zsh)
