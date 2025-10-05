# Setup fzf
# ---------

# Detectar ubicación de fzf según el usuario
if [ "$USER" = "root" ]; then
  FZF_PATH="/home/javi/.fzf/bin"
else
  FZF_PATH="$HOME/.fzf/bin"
fi

# Añadir al PATH si no está ya
if [[ ! "$PATH" == *"$FZF_PATH"* ]]; then
  PATH="${PATH:+${PATH}:}$FZF_PATH"
fi

# Cargar keybindings y completado usando ruta absoluta
if [ -x "$FZF_PATH/fzf" ]; then
  source <("$FZF_PATH/fzf" --zsh)
fi
