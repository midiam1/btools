#!/bin/bash

# Function for Option 1
update_system() {
    sudo apt -y update
}

# Function for Option 2
set_prompt() {
    # Use a 'here document' to safely append the complex string to .bashrc
    cat <<'EOF' >> "$HOME/.bashrc"

# Custom Prompt
export PS1='\[\e[34m\]\u\[\e[38;5;214m\]@\[\e[31m\]\h\[\e[38;5;214m\]:\[\e[38;5;202m\]$(pwd)\[\e[38;5;214m\]: \[\e[m\]'
EOF

    echo "Prompt actualizado. Para ver los cambios, reinicia tu terminal o ejecuta: source ~/.bashrc"
}

# Function for Option 3
install_mc() {
    sudo apt -y install mc
}

# Function for Option 4
install_webmin() {
    echo "Configurando el repositorio de Webmin..."
    # Download GPG key
    sudo wget -qO- http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
    
    # Add Webmin repository
    echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
    
    echo "Actualizando la lista de paquetes..."
    sudo apt-get update
    
    echo "Instalando Webmin..."
    sudo apt-get install -y webmin
    
    echo "Webmin instalado correctamente."
}

# Function for Option 5
install_cockpit() {
    echo "Instalando Cockpit..."
    sudo apt-get install -y cockpit
    echo "Cockpit instalado correctamente. Accede a través de https://tu-ip:9090"
}


# Main menu loop
while true; do
    echo "--- Main Menu ---"
    echo "1. Actualizar Sistema"
    echo "2. Pones Bonito el Prompt"
    echo "3. Instalar MC"
    echo "4. Instalar Webmin"
    echo "5. Instalar Cockpit"
    echo "6. Exit"
    echo "-----------------"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            update_system
            ;;
        2)
            set_prompt
            ;;
        3)
            install_mc
            ;;
        4)
            install_webmin
            ;;
        5)
            install_cockpit
            ;;
        6)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
    echo "" # Add a newline for better readability
done
