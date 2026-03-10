#!/bin/bash

# --- Compatibility Detection ---
# Detect package manager and set commands
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    UPDATE_CMD="sudo apt-get -y update"
    UPGRADE_CMD="sudo apt-get -y upgrade"
    INSTALL_CMD="sudo apt-get -y install"
    echo "Sistema basado en Debian detectado (usando APT)."
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="sudo dnf check-update" # dnf doesn't have a separate update command like apt
    UPGRADE_CMD="sudo dnf -y upgrade"
    INSTALL_CMD="sudo dnf -y install"
    echo "Sistema basado en Fedora/RPM detectado (usando DNF)."
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    UPDATE_CMD="sudo yum check-update"
    UPGRADE_CMD="sudo yum -y upgrade"
    INSTALL_CMD="sudo yum -y install"
    echo "Sistema basado en CentOS/RHEL detectado (usando YUM)."
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    # Pacman combines update and upgrade in -Syu
    UPDATE_CMD="sudo pacman -Syy"
    UPGRADE_CMD="sudo pacman -Syu --noconfirm"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    echo "Sistema basado en Arch detectado (usando Pacman)."
else
    echo "Error: No se pudo detectar un gestor de paquetes compatible (apt, dnf, yum, pacman)." >&2
    exit 1
fi

# Detect sudo group
if getent group sudo >/dev/null; then
    SUDO_GROUP="sudo"
elif getent group wheel >/dev/null; then
    SUDO_GROUP="wheel"
else
    echo "Advertencia: No se pudo encontrar el grupo 'sudo' o 'wheel'. Se usará 'sudo' por defecto."
    SUDO_GROUP="sudo"
fi
# --- End of Compatibility Detection ---


# Function for Option 1
update_system() {
    echo "Actualizando la lista de paquetes..."
    $UPDATE_CMD
    echo "Mejorando el sistema..."
    $UPGRADE_CMD
    echo "¡Sistema actualizado!"
}

# Function for Option 2
set_prompt() {
    # Appends the custom prompt to .bashrc
    cat <<'EOF' >> "$HOME/.bashrc"

# Custom Prompt
export PS1='\[\e[34m\]\u\[\e[38;5;214m\]@\[\e[31m\]\h\[\e[38;5;214m\]:\[\e[38;5;202m\]$(pwd)\[\e[38;5;214m\]: \[\e[m\]'
EOF
    echo "Prompt añadido a ~/.bashrc."
    
    # Reload .bashrc to apply changes to the current session
    # IMPORTANT: This will only work if the script is run with "source menu.sh"
    echo "Aplicando cambios en la sesión actual..."
    source "$HOME/.bashrc"
    
    echo "¡Prompt actualizado! Si no ves el cambio, ejecuta el menú con: source btools/menu.sh"
}

# Function for Option 3
install_mc() {
    echo "Instalando Midnight Commander (mc)..."
    $INSTALL_CMD mc
    echo "¡MC instalado!"
}

# Function for Option 4
install_webmin() {
    if [ "$PKG_MANAGER" == "apt" ]; then
        echo "Configurando el repositorio de Webmin para sistemas Debian/Ubuntu..."
        sudo wget -qO- http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
        echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
        $UPDATE_CMD
        $INSTALL_CMD webmin
    elif [ "$PKG_MANAGER" == "dnf" ] || [ "$PKG_MANAGER" == "yum" ]; then
        echo "Configurando el repositorio de Webmin para sistemas RPM..."
        sudo tee /etc/yum.repos.d/webmin.repo > /dev/null <<EOF
[Webmin]
name=Webmin Distribution Neutral
mirrorlist=https://download.webmin.com/download/yum/mirrorlist
enabled=1
EOF
        sudo rpm --import http://www.webmin.com/jcameron-key.asc
        $INSTALL_CMD webmin
    else
        echo "La instalación automática de Webmin no está soportada para tu sistema ($PKG_MANAGER)."
        echo "Por favor, visita http://www.webmin.com/download.html para instrucciones manuales."
        return
    fi
    echo "¡Webmin instalado correctamente!"
}

# Function for Option 5
install_cockpit() {
    echo "Instalando Cockpit..."
    $INSTALL_CMD cockpit
    sudo systemctl enable --now cockpit.socket
    echo "¡Cockpit instalado y activado! Accede a través de https://tu-ip:9090"
}

# Function for Option 6
create_sudo_user() {
    read -p "Introduce el nombre del nuevo usuario: " username
    if [ -z "$username" ]; then
        echo "El nombre de usuario no puede estar vacío."
        return
    fi
    read -s -p "Introduce la contraseña para $username: " password
    echo
    sudo useradd -m -s /bin/bash "$username"
    if [ $? -eq 0 ]; then
        echo "$username:$password" | sudo chpasswd
        sudo usermod -aG "$SUDO_GROUP" "$username"
        echo "Usuario '$username' creado y añadido al grupo '$SUDO_GROUP' correctamente."
        echo "Ahora puedes usar este usuario para acceder a Cockpit."
    else
        echo "Error al crear el usuario. ¿Quizás ya existe?"
    fi
}


# Main menu loop
while true; do
    echo "--- Main Menu (Modo Universal) ---"
    echo "1. Actualizar y Mejorar Sistema"
    echo "2. Poner Bonito el Prompt (ejecutar con 'source')"
    echo "3. Instalar MC (Midnight Commander)"
    echo "4. Instalar Webmin"
    echo "5. Instalar Cockpit"
    echo "6. Crear Usuario con Sudo"
    echo "7. Salir"
    echo "------------------------------------"
    read -p "Elige una opción: " choice

    case $choice in
        1) update_system ;;
        2) set_prompt ;;
        3) install_mc ;;
        4) install_webmin ;;
        5) install_cockpit ;;
        6) create_sudo_user ;;
        7) echo "Saliendo..."; break ;;
        *) echo "Opción no válida. Inténtalo de nuevo." ;;
    esac
    echo "" # Add a newline for better readability
done
