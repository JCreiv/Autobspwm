#!/bin/bash

# =========================================
# Instalador de herramientas de hacking
# OS: Parrot Security
# Autor: Jcreiv
# =========================================

set -e

# Función para imprimir en verde
print_green() {
    echo -e "\e[32m$1\e[0m"
}
# Función para imprimir en rojo
print_red() {
    echo -e "\033[31m$1\033[0m"
}

echo "[+] Actualizando sistema..."

os_name=$(grep '^NAME=' /etc/os-release | awk '{print $1 }' | tr '="' ' ' | awk '{print $2 }')

if [ "$os_name" = "Kali" ]; then
    print_green "Detected OS: Kali"
    sudo apt upgrade && sudo apt update -y
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

# -----------------------------------------
# VMWARE TOOLS
# -----------------------------------------

echo "[*] Instalando Open VM Tools..."
sudo apt install -y open-vm-tools open-vm-tools-desktop

echo "[*] Habilitando servicios de VM Tools..."
sudo systemctl enable --now open-vm-tools

echo "[*] Desactivando servicios innecesarios..."
sudo systemctl disable --now tor
sudo systemctl disable --now cups
sudo systemctl disable --now bluetooth
sudo systemctl disable --now NetworkManager-wait-online

# -----------------------------------------
# INSTALAR GO 1.25.5
# -----------------------------------------
echo "[+] Instalando Go 1.25.5..."

GO_TAR="go1.25.5.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_TAR}"

# -----------------------------------------
# DESCARGAR GO SI NO EXISTE
# -----------------------------------------
if [ ! -f "$GO_TAR" ]; then
    echo "[+] Descargando $GO_TAR..."
    curl -LO "$GO_URL"
fi

# -----------------------------------------
# ELIMINAR GO ANTIGUO E INSTALAR NUEVO
# -----------------------------------------
if [ -f "$GO_TAR" ]; then
    echo "[+] Eliminando Go anterior (/usr/local/go)..."
    sudo rm -rf /usr/local/go

    echo "[+] Extrayendo $GO_TAR en /usr/local..."
    sudo tar -C /usr/local -xzf "$GO_TAR"
else
    echo "[!] No se encontró $GO_TAR — saltando instalación de Go"
fi

# -----------------------------------------
# CONFIGURAR PATH (ZSH)
# -----------------------------------------
# Añadir /usr/local/go/bin al PATH de forma permanente y temporal
GO_PATH_LINE='export PATH=/usr/local/go/bin:$PATH'

# Añadir solo si no existe en .zshrc
if ! grep -Fxq "$GO_PATH_LINE" ~/.zshrc; then
    echo "[+] Añadiendo Go al PATH en ~/.zshrc..."
    echo "$GO_PATH_LINE" >> ~/.zshrc
fi

# Añadir al PATH de la terminal actual (temporal)
export PATH=/usr/local/go/bin:$PATH

echo "[✔] Go instalado o ya presente"


# -----------------------------------------
# DEPENDENCIAS BASE
# -----------------------------------------
echo "[+] Instalando dependencias base..."
sudo apt install -y \
    git curl wget unzip \
    python3 python3-pip python3-venv \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release

# -----------------------------------------
# HERRAMIENTAS APT (CORE)
# -----------------------------------------
echo "[+] Instalando herramientas vía APT..."
sudo apt install -y \
    nmap \
    masscan \
    netcat-traditional \
    tcpdump \
    wireshark \
    sqlmap \
    gobuster \
    wfuzz \
    nikto \
    hydra \
    john \
    hashcat \
    smbclient \
    ldap-utils \
    enum4linux-ng \
    responder \
    impacket-scripts

# -----------------------------------------
# CONFIG GO
# -----------------------------------------
echo "[+] Configurando Go..."
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

if ! grep -q "GOPATH" ~/.zshrc; then
    echo 'export GOPATH=$HOME/go' >> ~/.zshrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.zshrc
fi

# -----------------------------------------
# HERRAMIENTAS GO (RECON / WEB)
# -----------------------------------------
echo "[+] Instalando herramientas en Go..."
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/owasp-amass/amass/v4/cmd/amass@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/lc/gau/v2/cmd/gau@latest

# -----------------------------------------
# DOCKER
# -----------------------------------------
echo "[+] Instalando Docker..."

# -----------------------------------------
# Eliminar versiones antiguas
# -----------------------------------------
sudo apt remove -y $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1) || true

# -----------------------------------------
# Instalar dependencias
# -----------------------------------------
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# -----------------------------------------
# Crear carpeta para GPG
# -----------------------------------------
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# -----------------------------------------
# Añadir Docker repository (usar bookworm para Parrot Lory)
# -----------------------------------------
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: bookworm
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# -----------------------------------------
# Actualizar lista de paquetes
# -----------------------------------------
sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
