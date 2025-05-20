# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#Fix the java problem
export _JAVA_AWT_WM_NONREPARENTING=1


source /home/javi/powerlevel10k/powerlevel10k.zsh-theme

#ZSH autosuggestion
if [ -f /usr/share/zsh-autosuggestion/zsh-autosuggestion.zsh ]; then
	source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

#ZSH Syntax

if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#ZSH autocomplete

#if [ -f /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]; then
 #   source /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
#fi

#ZSH sudo

if [ -f /usr/share/zsh-sudo/sudo.plugin.zsh ]; then
    source /usr/share/zsh-sudo/sudo.plugin.zsh
fi

# Custom Aliases
# -----------------------------------------------
# bat
alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'


# ls
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias lll='ls -la'

#xclip
alias toclip="xclip -selection clipboard"

#grep
alias grep='grep --color=auto'

#History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000 
setopt histignorealldups sharehistory incappendhistory

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


export LS_COLORS="rs=0:di=34:ln=36:mh=00:pi=40;33:so=35:do=35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=32:*.tar=31:*.tgz=31:*.arc=31:*.arj=31:*.taz=31:*.lha=31:*.lz4=31:*.lzh=31:*.lzma=31:*.tlz=31:*.txz=31:*.tzo=31:*.t7z=31:*.zip=31:*.z=31:*.dz=31:*.gz=31:*.lrz=31:*.lz=31:*.lzo=31:*.xz=31:*.zst=31:*.tzst=31:*.bz2=31:*.bz=31:*.tbz=31:*.tbz2=31:*.tz=31:*.deb=31:*.rpm=31:*.jar=31:*.war=31:*.ear=31:*.sar=31:*.rar=31:*.alz=31:*.ace=31:*.zoo=31:*.cpio=31:*.7z=31:*.rz=31:*.cab=31:*.wim=31:*.swm=31:*.dwm=31:*.esd=31:*.avif=35:*.jpg=35:*.jpeg=35:*.mjpg=35:*.mjpeg=35:*.gif=35:*.bmp=35:*.pbm=35:*.pgm=35:*.ppm=35:*.tga=35:*.xbm=35:*.xpm=35:*.tif=35:*.tiff=35:*.png=35:*.svg=35:*.svgz=35:*.mng=35:*.pcx=35:*.mov=35:*.mpg=35:*.mpeg=35:*.m2v=35:*.mkv=35:*.webm=35:*.webp=35:*.ogm=35:*.mp4=35:*.m4v=35:*.mp4v=35:*.vob=35:*.qt=35:*.nuv=35:*.wmv=35:*.asf=35:*.rm=35:*.rmvb=35:*.flc=35:*.avi=35:*.fli=35:*.flv=35:*.gl=35:*.dl=35:*.xcf=35:*.xwd=35:*.yuv=35:*.cgm=35:*.emf=35:*.ogv=35:*.ogx=35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.swp=00;90:*.tmp=00;90:*.dpkg-dist=00;90:*.dpkg-old=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:"

export PATH=/opt/kitty/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/sbin/:/opt/nvim/nvim-linux64/bin:/snap/bin:/home/javi/go/bin 

#Custom function
#----------------------------

#Delete all files

nuke() {
  local keep=("${@}")
  local find_cmd="find . -maxdepth 1"
  local preview_cmd="find . -maxdepth 1"

  for file in "${keep[@]}"; do
    find_cmd+=" ! -name '${file}'"
    preview_cmd+=" ! -name '${file}'"
  done

  find_cmd+=" ! -name '.' -exec rm -rf {} +"
  preview_cmd+=" ! -name '.' -print"

  echo "🧹 Archivos/directorios que se eliminarán:"
  eval "$preview_cmd"

  echo
  print -n "⚠️  ¿Estás seguro de querer eliminar esos archivos? (escribe 'y' para continuar): "
  read confirm1
  if [[ "$confirm1" != "y" ]]; then
    echo "❌ Cancelado."
    return 1
  fi

  echo "✅ Ejecutando: $find_cmd"
  eval "$find_cmd"
}



#Set Victim Target

function settarget(){
    ip_address=$1
    machine_name=$2
    echo "$ip_address $machine_name" > /home/javi/.config/bin/target
}

#Clear Victim Target

function cleartarget(){
    echo '' > /home/javi/.config/bin/target
}

#Directory maker
function mkt(){
    mkdir {nmap,content,exploits,scripts}
}


# Extract nmap information
function extractPorts(){
    ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
    ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
    echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
    echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
    echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
    echo $ports | tr -d '\n' | xclip -sel clip
    echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
    cat extractPorts.tmp; rm extractPorts.tmp
}

# Show images one by one
: <<'COMENTARIO'
img() { 
  for f in "$@"; do
    clear
    tput civis
    printf "\n\033[1;32mMostrando:\033[0m %s\n\n" "$f"
    sleep 0.4
    kitty +kitten icat "$f"
    printf "\n\033[1;33mPresiona ENTER para continuar...\033[0m"
    read -r
    clear
  done
  tput cnorm
}
COMENTARIO

# Show images all at once
img() {
  for f in "$@"; do
    tput civis
    printf "\n\033[1;32mMostrando:\033[0m %s\n\n" "$f"
    kitty +kitten icat "$f"
    sleep 0.4
  done
  tput cnorm
}



# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Created by `pipx` on 2024-09-25 15:52:21
export PATH="$PATH:/home/javi/.local/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Golang vars
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH

#Expresiones regulares
setopt extendedglob

PATH=~/.console-ninja/.bin:$PATH
