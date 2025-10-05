#!/bin/bash

function ctrl_c(){
  echo -e "\n\n[!] Saliendo...\n"
  exit 1
   }

#Ctrl_C
trap ctrl_c INT


# Función para imprimir en verde
print_green() {
    echo -e "\e[32m$1\e[0m"
}
# Función para imprimir en rojo
print_red() {
    echo -e "\033[31m$1\033[0m"
}


# Install figlet
    sudo apt update && install -y figlet
	sudo wget -O /usr/share/figlet/slant.flf http://www.figlet.org/fonts/slant.flf

# Use figlet
clear
figlet -f slant "Autobspwm"
print_green "Created by JCreiv"
print_green "https://github.com/JCreiv"
echo
echo

if command -v systemd-detect-virt &>/dev/null; then
    VIRT_TYPE=$(systemd-detect-virt)
else
    VIRT_TYPE="unknown"
fi

if [[ "$VIRT_TYPE" == "none" ]]; then
    print_red "Hardware físico."
elif [[ "$VIRT_TYPE" == "unknown" ]]; then
	print_red "VM u otro hypervisor: $VIRT_TYPE"
else
    print_green "VM: $VIRT_TYPE"

    # Comprobar si es VMware
    if [[ "$VIRT_TYPE" == "vmware" ]]; then
        print_green "Instalando tools vmware"
        sudo apt install -y open-vm-tools open-vm-tools-desktop
    fi
fi

#Comprobar el OS

os_name=$(grep '^NAME=' /etc/os-release | awk '{print $1 }' | tr '="' ' ' | awk '{print $2 }')

if [ "$os_name" = "Kali" ]; then
    print_green "Detected OS: Kali"
    sudo apt upgrade && sudo apt update -y
    sudo apt install feh
    sudo apt install bspwm
elif [ "$os_name" = "Parrot" ]; then
    print_green "Detected OS: Parrot"
    sudo parrot-upgrade -y && sudo apt update
elif [ "$os_name" = "Ubuntu" ]; then
    print_green "Detected OS: Ubuntu"
    sudo apt upgrade && sudo apt update -y
else 
    read -p "Unrecognized OS. Do you want to continue? (y/n): " respuesta
    if [ "$respuesta" != "y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

# Ruta del archivo de configuración de nano
NANORC="$HOME/.nanorc"

# Paso 1: Asegurar que ~/.nanorc incluye los archivos del sistema
grep -q "/usr/share/nano/*.nanorc" "$NANORC" 2>/dev/null || echo 'include /usr/share/nano/*.nanorc' >> "$NANORC"

# Paso 2: Instalar esquema de resaltado avanzado (scopatz/nanorc)

# Elimina versiones anteriores si existen (opcional)
rm -rf "$HOME/.nano"

# Clona el repositorio
git clone https://github.com/scopatz/nanorc.git "$HOME/.nano"

# Asegura que ~/.nanorc incluye los archivos clonados
grep -q "$HOME/.nano" "$NANORC" || echo "include $HOME/.nano/*.nanorc" >> "$NANORC"



# Comprobación de tarjeta de red

red=$(ip link show | grep '^2:' | awk '{print $2}' | tr -d ':')

if [ "$red" = eth0 ]; then
    sed -i 's/ens33/eth0/g' ./config/bspwm/scripts/ethernet_status.sh
fi



# Ruta de archivos de configuracion
ruta=$(pwd)

# Evitar ejecución como root
if [ "$(whoami)" == "root" ]; then
    echo -e "\e[31m❌ Dont execute this script as root.\e[0m"
    exit 1
fi


# Instalar dependencias del entorno general

sudo apt update
sudo apt install -y \
    build-essential git vim xcb \
    libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
    libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev \
    libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev net-tools

print_green "✅ Dependencias generales instaladas."

# Dependencias para Polybar (compilación desde código fuente)

sudo apt install -y \
    cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev \
    libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen \
    xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev \
    libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev \
    libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev


# Dependencias para Picom (compilación desde código fuente)

sudo apt install -y \
    meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev \
    libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev \
    libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev \
    libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev \
    libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev \
    libx11-xcb-dev libxcb-glx0-dev libpcre3 libpcre3-dev


# Instalación de herramientas adicionales para el entorno

sudo apt install -y \
    feh flameshot scrub zsh rofi xclip bat locate neofetch wmname \
    acpi bspwm sxhkd imagemagick ranger kitty i3lock-fancy


# Crear carpeta de trabajo y clonar repositorios
print_green "Preparing directory ~/github"

mkdir -p ~/github
cd ~/github || exit 1

# Clonar Polybar si no existe
if [ ! -d "polybar" ]; then
    print_green "🔽 Cloning Polybar..."
    git clone --recursive https://github.com/polybar/polybar
else
    print_green "Polybar is already cloned"
fi

# Clonar Picom si no existe
if [ ! -d "picom" ]; then
    git clone https://github.com/ibhagwan/picom.git
else
    print_green "Picom is already cloned"
fi

# Compilar e instalar Polybar

if [ -d ~/github/polybar ]; then
    cd ~/github/polybar || exit 1
    mkdir -p build
    cd build || exit 1

    cmake ..
    make -j"$(nproc)"
    sudo make install

else
    print_red "❌ Directory ~/github/polybar not found."
fi

# Compilar e instalar Picom (ibhagwan)

if [ -d ~/github/picom ]; then
    cd ~/github/picom || exit 1
    git submodule update --init --recursive

    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install

else
    print_red "❌ Directory ~/github/picom not found."
fi


# Instalar Powerlevel10k

MAX_TRIES=3
try=1

if [ ! -d ~/.powerlevel10k ]; then
    while [ $try -le $MAX_TRIES ]; do
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k && break
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k && break
        try=$((try+1))
        sleep 2
    done

    if [ -d ~/.powerlevel10k ]; then
        echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
    else
        print_red "❌ No se pudo clonar Powerlevel10k despues de $MAX_TRIES intentos."
    fi
else
    print_green "Powerlevel10k is alredy installed in ~/.powerlevel10k"
fi


# Ahora instalacion para root (solo si no existe)
if sudo [ ! -d /root/.powerlevel10k ]; then
    sudo cp -r ~/.powerlevel10k  /root/.powerlevel10k
    print_green "Powerlevel10k instalado para root"
else
    print_green "Powerlevel10k is alredy installed in /root/.powerlevel10k"
fi



# Instalación de fuentes, lsd y fondos de pantalla


if [ -f "$ruta/lsd.deb" ]; then
    sudo dpkg -i "$ruta/lsd.deb"
else
    print_red "❌ Not found $ruta/lsd.deb"
fi

if [ -f "$ruta/bat.deb" ]; then
    sudo dpkg -i "$ruta/bat.deb"
else
    print_red "❌ Not found $ruta/bat.deb"
fi


if [ -d "$ruta/fonts/HNF" ]; then
    sudo cp -v "$ruta/fonts/HNF/"* /usr/local/share/fonts/
else
    print_red "❌ Not found $ruta/fonts/HNF"
fi


if [ -d "$ruta/config/polybar/fonts" ]; then
    sudo cp -v "$ruta/config/polybar/fonts/"* /usr/share/fonts/truetype/
else
    print_red "❌ Not found $ruta/config/polybar/fonts"
fi


mkdir -p ~/Wallpapers

if [ -d "$ruta/Wallpapers" ]; then
    cp -v "$ruta/Wallpapers/"* ~/Wallpapers
else
    print_red "❌ Not found $ruta/Wallpapers"
fi


if [ -d "$ruta/.fzf" ]; then
	cp -r "$ruta/.fzf" ~/
	cp "$ruta/.fzf.zsh" ~/
	sudo cp -r "$ruta/.fzf" /root/
    sudo cp "$ruta/.fzf.zsh" /root/
fi


# Copiar configuración personalizada del entorno

# Config ~/.config/

rm -rf ~/.config/polybar 2>/dev/null
cp -rv "$ruta/config/"* ~/.config/

# Config kitty (requiere sudo)

if [ -d "$ruta/kitty" ]; then
    sudo cp -rv "$ruta/kitty" /opt/
else
    print_red "❌ Not found $ruta/kitty"
fi

# Configuración de .zshrc y .p10k.zsh

if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.bak
fi

cp -v "$ruta/.zshrc" ~/.zshrc
cp -v "$ruta/.p10k.zsh" ~/.p10k.zsh

# Para root
sudo cp -v "$ruta/.p10k-root.zsh" /root/.p10k.zsh


# Zsh plugins y permisos


sudo apt install -y zsh-syntax-highlighting zsh-autosuggestions

# sudo.plugin.zsh manual
if [ ! -f /usr/share/zsh-sudo/sudo.plugin.zsh ]; then
    sudo mkdir -p /usr/share/zsh-sudo
    cd /usr/share/zsh-sudo || exit 1
    sudo wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
else
    print_green "✔️  sudo.plugin.zsh yis alredy installed"
fi

# .zshrc para root (enlace simbólico)

sudo ln -sfv ~/.zshrc /root/.zshrc

# Permisos de scripts

chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/scripts/bspwm_resize
chmod +x ~/.config/bspwm/scripts/ethernet_status.sh
chmod +x ~/.config/bspwm/scripts/victim_to_hack.sh
chmod +x ~/.config/bspwm/scripts/vpn_status.sh
chmod +x ~/.config/polybar/launch.sh

print_green "Changing type SHELL to Zsh"
chsh -s $(which zsh)
sudo chsh -s /usr/bin/zsh root


print_green "✅ Configuration completed. The system will reboot in 5 seconds..."
sleep 5
sudo reboot now
