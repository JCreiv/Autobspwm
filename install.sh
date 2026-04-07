#!/bin/bash
 
# ─────────────────────────────────────────────
#  Configuración global
# ─────────────────────────────────────────────
set -euo pipefail
 
# Ctrl+C handler
function ctrl_c() {
    echo -e "\n\n[!] Saliendo...\n"
    exit 1
}
trap ctrl_c INT
 
# ─────────────────────────────────────────────
#  Funciones de utilidad
# ─────────────────────────────────────────────
print_green() { echo -e "\e[32m$1\e[0m"; }
print_red()   { echo -e "\e[31m$1\e[0m"; }
print_yellow(){ echo -e "\e[33m$1\e[0m"; }
 
# ─────────────────────────────────────────────
#  Comprobación de root (PRIMERO, antes de todo)
# ─────────────────────────────────────────────
if [ "$(id -u)" -eq 0 ]; then
    print_red "❌ No ejecutes este script como root."
    exit 1
fi
 
# ─────────────────────────────────────────────
#  Banner
# ─────────────────────────────────────────────
if ! command -v figlet &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq figlet
fi
 
SLANT_FONT="/usr/share/figlet/slant.flf"
if [ ! -f "$SLANT_FONT" ]; then
    sudo wget -q -O "$SLANT_FONT" http://www.figlet.org/fonts/slant.flf
fi
 
clear
figlet -f slant "Autobspwm"
print_green "Created by JCreiv"
print_green "https://github.com/JCreiv"
echo
 
# ─────────────────────────────────────────────
#  Detección de virtualización
# ─────────────────────────────────────────────
if command -v systemd-detect-virt &>/dev/null; then
    VIRT_TYPE=$(systemd-detect-virt)
else
    VIRT_TYPE="unknown"
fi
 
case "$VIRT_TYPE" in
    none)
        print_yellow "⚠️  Hardware físico detectado."
        ;;
    vmware)
        print_green "VM detectada: VMware. Instalando open-vm-tools..."
        sudo apt-get install -y open-vm-tools open-vm-tools-desktop
        ;;
    unknown)
        print_yellow "⚠️  No se pudo determinar el tipo de virtualización."
        ;;
    *)
        print_green "VM detectada: $VIRT_TYPE"
        ;;
esac
 
# ─────────────────────────────────────────────
#  Detección del sistema operativo
# ─────────────────────────────────────────────
os_name=$(grep '^NAME=' /etc/os-release | cut -d'"' -f2 | awk '{print $1}')
 
case "$os_name" in
    Kali)
        print_green "OS detectado: Kali"
        sudo apt-get update -qq && sudo apt-get upgrade -y
        ;;
    Parrot)
        print_green "OS detectado: Parrot"
        sudo parrot-upgrade -y && sudo apt-get update -qq
        ;;
    Ubuntu)
        print_green "OS detectado: Ubuntu"
        sudo apt-get update -qq && sudo apt-get upgrade -y
        ;;
    *)
        print_yellow "OS no reconocido: $os_name"
        read -rp "¿Deseas continuar de todas formas? (s/n): " respuesta
        if [[ "$respuesta" != "s" && "$respuesta" != "S" ]]; then
            echo "Abortado."
            exit 1
        fi
        ;;
esac
 
# ─────────────────────────────────────────────
#  Configuración de nanorc
# ─────────────────────────────────────────────

configure_nanorc() {
    local dest="$1"
    local use_sudo="$2"
    local nanorc="$dest/.nanorc"
    local nano_dir="$dest/.nano"

    if [ "$use_sudo" = "true" ]; then
        sudo grep -q "/usr/share/nano/\*.nanorc" "$nanorc" 2>/dev/null || \
            echo 'include /usr/share/nano/*.nanorc' | sudo tee -a "$nanorc" > /dev/null

        if sudo [ -d "$nano_dir" ]; then
            print_green "✔️  Configuración de nano ya existe en $dest. Omitiendo clonado."
        else
            sudo git clone https://github.com/scopatz/nanorc.git "$nano_dir"
        fi

        sudo grep -q "$nano_dir" "$nanorc" 2>/dev/null || \
            echo "include $nano_dir/*.nanorc" | sudo tee -a "$nanorc" > /dev/null
    else
        grep -q "/usr/share/nano/\*.nanorc" "$nanorc" 2>/dev/null || \
            echo 'include /usr/share/nano/*.nanorc' >> "$nanorc"

        if [ -d "$nano_dir" ]; then
            print_green "✔️  Configuración de nano ya existe en $dest. Omitiendo clonado."
        else
            git clone https://github.com/scopatz/nanorc.git "$nano_dir"
        fi

        grep -q "$nano_dir" "$nanorc" 2>/dev/null || \
            echo "include $nano_dir/*.nanorc" >> "$nanorc"
    fi
}

configure_nanorc "$HOME" "false"
configure_nanorc "/root" "true"
 
# ─────────────────────────────────────────────
#  Detección de interfaz de red
# ─────────────────────────────────────────────
ruta=$(pwd)
red=$(ip link show | awk '/^2:/{print $2}' | tr -d ':')
ETHERNET_SCRIPT="$ruta/config/bspwm/scripts/ethernet_status.sh"
 
if [ "$red" = "eth0" ] && [ -f "$ETHERNET_SCRIPT" ]; then
    sed -i 's/ens33/eth0/g' "$ETHERNET_SCRIPT"
fi
 
# ─────────────────────────────────────────────
#  Instalación de paquetes
# ─────────────────────────────────────────────
print_green "Instalando paquetes necesarios..."
sudo apt-get install -y \
    feh flameshot scrub zsh rofi xclip bat locate fastfetch suckless-tools acpi \
    bspwm sxhkd imagemagick ranger i3lock-fancy git lsd kitty polybar \
    picom nano unzip fonts-noto-color-emoji zsh-syntax-highlighting \
    zsh-autosuggestions wget
 
# ─────────────────────────────────────────────
#  Zsh: .zshrc y .p10k.zsh
# ─────────────────────────────────────────────
[ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak" && \
    print_yellow "⚠️  Backup creado: ~/.zshrc.bak"
 
cp -v "$ruta/config/.zshrc"          "$HOME/.zshrc"
cp -v "$ruta/config/.p10k.zsh"       "$HOME/.p10k.zsh"
 
sudo cp -v "$ruta/config/.zshrc"     /root/.zshrc
sudo sed -i "s|$HOME|/root|g"        /root/.zshrc
sudo cp -v "$ruta/config/.p10k-root.zsh" /root/.p10k-root.zsh
 
# ─────────────────────────────────────────────
#  Powerlevel10k (usuario + root)
# ─────────────────────────────────────────────
echo -ne "\n[+] Instalando Powerlevel10k\n"
 
install_p10k() {
    local dest="$1"
    local use_sudo="$2"
    local zshrc="$dest/.zshrc"
    local p10k_dir="$dest/.powerlevel10k"
 
    if [ -d "$p10k_dir" ]; then
        print_green "✔️  Powerlevel10k ya instalado en $p10k_dir"
        return 0
    fi
 
    if [ "$use_sudo" = "true" ]; then
        sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        sudo grep -q "powerlevel10k.zsh-theme" "$zshrc" 2>/dev/null || \
            echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' | sudo tee -a "$zshrc" > /dev/null
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        grep -q "powerlevel10k.zsh-theme" "$zshrc" 2>/dev/null || \
            echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> "$zshrc"
    fi
}
 
install_p10k "$HOME" "false"
install_p10k "/root" "true"
print_green "✔️  Powerlevel10k configurado para usuario y root."
 
# ─────────────────────────────────────────────
#  Fuentes
# ─────────────────────────────────────────────
if [ -d "$ruta/fonts/HNF" ]; then
    sudo cp -v "$ruta/fonts/HNF/"* /usr/local/share/fonts/
else
    print_red "❌ No encontrado: $ruta/fonts/HNF"
fi
 
if [ -d "$ruta/config/polybar/fonts" ]; then
    sudo cp -v "$ruta/config/polybar/fonts/"* /usr/share/fonts/truetype/
else
    print_red "❌ No encontrado: $ruta/config/polybar/fonts"
fi
 
# ─────────────────────────────────────────────
#  Wallpapers
# ─────────────────────────────────────────────
mkdir -p ~/Wallpapers
if [ -d "$ruta/Wallpapers" ]; then
    cp -v "$ruta/Wallpapers/"* ~/Wallpapers/
else
    print_red "❌ No encontrado: $ruta/Wallpapers"
fi
 
# ─────────────────────────────────────────────
#  fzf
# ─────────────────────────────────────────────
echo -ne "\n[+] Instalando fzf\n"
 
install_fzf() {
    local dest="$1"
    local use_sudo="$2"
 
    if [ -d "$dest/.fzf" ]; then
        print_green "✔️  fzf ya instalado en $dest/.fzf"
        return 0
    fi
 
    if [ "$use_sudo" = "true" ]; then
        sudo git clone --depth=1 https://github.com/junegunn/fzf.git "$dest/.fzf"
        sudo env SHELL=/bin/zsh HOME="$dest" "$dest/.fzf/install" --all --no-bash --no-fish
    else
        git clone --depth=1 https://github.com/junegunn/fzf.git "$dest/.fzf"
        env SHELL=/bin/zsh "$dest/.fzf/install" --all --no-bash --no-fish
    fi
}
 
install_fzf "$HOME" "false"
install_fzf "/root" "true"
print_green "✔️  fzf instalado para usuario y root."
 
# ─────────────────────────────────────────────
#  Configuración del entorno (~/.config)
# ─────────────────────────────────────────────
 
cp -rv "$ruta/config/"* "$HOME/.config/"
 
# Restaurar .zshrc por si el cp lo sobreescribió
cp -v "$ruta/config/.zshrc" "$HOME/.zshrc"
 
# ─────────────────────────────────────────────
#  sudo.plugin.zsh
# ─────────────────────────────────────────────
SUDO_PLUGIN="/usr/share/zsh-sudo/sudo.plugin.zsh"
SUDO_PLUGIN_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh"
 
if [ ! -f "$SUDO_PLUGIN" ]; then
    sudo mkdir -p /usr/share/zsh-sudo
    sudo wget -q -O "$SUDO_PLUGIN" "$SUDO_PLUGIN_URL"
else
    print_green "✔️  sudo.plugin.zsh ya instalado."
fi
 
# ─────────────────────────────────────────────
#  Permisos de scripts
# ─────────────────────────────────────────────
chmod +x "$HOME/.config/bspwm/bspwmrc"
chmod +x "$HOME/.config/bspwm/scripts/bspwm_resize"
chmod +x "$HOME/.config/bspwm/scripts/ethernet_status.sh"
chmod +x "$HOME/.config/bspwm/scripts/victim_to_hack.sh"
chmod +x "$HOME/.config/bspwm/scripts/vpn_status.sh"
chmod +x "$HOME/.config/polybar/launch.sh"