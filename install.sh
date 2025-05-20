#!/bin/bash

# Ruta de archivos de configuracion
ruta=$(pwd)

# Evitar ejecución como root
if [ "$(whoami)" == "root" ]; then
    echo -e "\e[31m❌ No ejecutes este script como root.\e[0m"
    exit 1
fi

# Función para imprimir en verde
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Función para imprimir en amarillo
print_yellow() {
    echo -e "\e[33m$1\e[0m"
}

# Instalar dependencias del entorno general
print_green "Instalando dependencias generales del sistema..."

sudo apt update
sudo apt install -y \
    build-essential git vim xcb \
    libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
    libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev \
    libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev net-tools

print_green "✅ Dependencias generales instaladas."

# Dependencias para Polybar (compilación desde código fuente)
print_green "Instalando dependencias para compilar Polybar..."

sudo apt install -y \
    cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev \
    libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen \
    xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev \
    libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev \
    libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev

print_green "✅ Dependencias de Polybar instaladas."

# Dependencias para Picom (compilación desde código fuente)
print_green "Instalando dependencias para compilar Picom..."

sudo apt install -y \
    meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev \
    libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev \
    libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev \
    libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev \
    libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev \
    libx11-xcb-dev libxcb-glx0-dev libpcre3 libpcre3-dev

print_green "✅ Dependencias de Picom instaladas."

# Instalación de herramientas adicionales para el entorno
print_green "Instalando herramientas adicionales..."

sudo apt install -y \
    feh flameshot scrub zsh rofi xclip bat locate neofetch wmname \
    acpi bspwm sxhkd imagemagick ranger kitty

print_green "✅ Herramientas adicionales instaladas."

# Crear carpeta de trabajo y clonar repositorios
print_green "Preparando carpeta de trabajo en ~/github"

mkdir -p ~/github
cd ~/github || exit 1

# Clonar Polybar si no existe
if [ ! -d "polybar" ]; then
    print_green "🔽 Clonando Polybar..."
    git clone --recursive https://github.com/polybar/polybar
else
    print_green "✔️  Polybar ya está clonado."
fi

# Clonar Picom si no existe
if [ ! -d "picom" ]; then
    print_green "🔽 Clonando Picom (ibhagwan)..."
    git clone https://github.com/ibhagwan/picom.git
else
    print_green "✔️  Picom ya está clonado."
fi

# Compilar e instalar Polybar
print_green "Compilando e instalando Polybar"

if [ -d ~/github/polybar ]; then
    cd ~/github/polybar || exit 1
    mkdir -p build
    cd build || exit 1

    cmake ..
    make -j"$(nproc)"
    sudo make install

    print_green "✅ Polybar instalado correctamente."
else
    print_red "❌ La carpeta ~/github/polybar no existe."
fi

# Compilar e instalar Picom (ibhagwan)
print_green "Compilando e instalando Picom (ibhagwan fork)"

if [ -d ~/github/picom ]; then
    cd ~/github/picom || exit 1
    git submodule update --init --recursive

    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install

    print_green "✅ Picom instalado correctamente."
else
    print_red "❌ La carpeta ~/github/picom no existe."
fi


# Instalar Powerlevel10k
print_green "Instalando Powerlevel10k para el usuario..."

MAX_TRIES=3
try=1

if [ ! -d ~/.powerlevel10k ]; then
    print_green "Clonando Powerlevel10k en ~/.powerlevel10k"
    while [ $try -le $MAX_TRIES ]; do
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k && break
        print_red "Intento $try de $MAX_TRIES fallido. Reintentando en 2 segundos..."
        try=$((try+1))
        sleep 2
    done

    if [ -d ~/.powerlevel10k ]; then
        echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
        print_green "✅ Powerlevel10k instalado y anadido a ~/.zshrc"
    else
        print_red "❌ No se pudo clonar Powerlevel10k despues de $MAX_TRIES intentos."
    fi
else
    print_green "✔️  Powerlevel10k ya esta instalado en ~/.powerlevel10k"
fi



# Instalación de fuentes, lsd y fondos de pantalla

print_green "Instalando lsd y bat desde archivo .deb"

if [ -f "$ruta/lsd.deb" ]; then
    sudo dpkg -i "$ruta/lsd.deb"
    print_green "✅ lsd instalado correctamente."
else
    print_red "❌ No se encontró $ruta/lsd.deb"
fi

if [ -f "$ruta/bat.deb" ]; then
    sudo dpkg -i "$ruta/bat.deb"
    print_green "✅ bat instalado correctamente."
else
    print_red "❌ No se encontró $ruta/bat.deb"
fi

print_green "Instalando Hack Nerd Fonts"

if [ -d "$ruta/fonts/HNF" ]; then
    sudo cp -v "$ruta/fonts/HNF/"* /usr/local/share/fonts/
    print_green "✅ Hack Nerd Fonts copiadas a /usr/local/share/fonts/"
else
    print_red "❌ No se encontró la carpeta $ruta/fonts/HNF"
fi

print_green "Instalando fuentes de Polybar"

if [ -d "$ruta/config/polybar/fonts" ]; then
    sudo cp -v "$ruta/config/polybar/fonts/"* /usr/share/fonts/truetype/
    print_green "✅ Fuentes de Polybar copiadas a /usr/share/fonts/truetype/"
else
    print_red "❌ No se encontró la carpeta $ruta/config/polybar/fonts"
fi

print_green "Copiando wallpapers y creando carpetas"

mkdir -p ~/Wallpapers

if [ -d "$ruta/Wallpapers" ]; then
    cp -v "$ruta/Wallpapers/"* ~/Wallpapers
    print_green "✅ Wallpapers copiados a ~/Wallpapers"
else
    print_red "❌ No se encontró la carpeta $ruta/Wallpapers"
fi

print_green "Añadir fzf"

if [ -d "$ruta/.fzf" ]; then
	cp -r "$ruta/.fzf" ~/
	cp "$ruta/.fzf.zsh" ~/
	print_green "✅ fzf copiado correctamente"


# Copiar configuración personalizada del entorno
print_green "Copiando archivos de configuración del entorno..."

# Config ~/.config/
print_green "🗂️  Configuración en ~/.config"

rm -rf ~/.config/polybar 2>/dev/null
cp -rv "$ruta/config/"* ~/.config/

# Config kitty (requiere sudo)
print_green "🖥️  Configuración de Kitty en /opt"

if [ -d "$ruta/kitty" ]; then
    sudo cp -rv "$ruta/kitty" /opt/
else
    print_red "❌ No se encontró $ruta/kitty"
fi

# Configuración de .zshrc y .p10k.zsh
print_green "🧠 Archivos .zshrc y .p10k.zsh"

if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.bak
    print_green "🛡️  Backup de .zshrc hecho en ~/.zshrc.bak"
fi

cp -v "$ruta/.zshrc" ~/.zshrc
cp -v "$ruta/.p10k.zsh" ~/.p10k.zsh

# Para root
sudo cp -v "$ruta/.p10k-root.zsh" /root/.p10k.zsh


# Zsh plugins y permisos

print_green "Instalando plugins de Zsh"

sudo apt install -y zsh-syntax-highlighting zsh-autosuggestions

# sudo.plugin.zsh manual
if [ ! -f /usr/share/zsh-sudo/sudo.plugin.zsh ]; then
    sudo mkdir -p /usr/share/zsh-sudo
    cd /usr/share/zsh-sudo || exit 1
    sudo wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
    print_green "✅ sudo.plugin.zsh descargado"
else
    print_green "✔️  sudo.plugin.zsh ya está presente"
fi

# .zshrc para root (enlace simbólico)
print_green "Enlazando .zshrc de root"

sudo ln -sfv ~/.zshrc /root/.zshrc

# Permisos de scripts
print_green "Asignando permisos de ejecución a scripts"

chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/scripts/bspwm_resize
chmod +x ~/.config/bspwm/scripts/ethernet_status.sh
chmod +x ~/.config/bspwm/scripts/victim_to_hack.sh
chmod +x ~/.config/bspwm/scripts/vpn_status.sh
chmod +x ~/.config/polybar/launch.sh

print_green "Cambiando el tipo de SHELL a Zsh"
chsh -s $(which zsh)
sudo chsh -s /usr/bin/zsh root


print_green "✅ Configuracion terminada. El sistema se reiniciara en 5 segundos..."
sleep 5
sudo reboot now
