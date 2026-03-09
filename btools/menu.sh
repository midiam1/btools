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

# Main menu loop
while true; do
    echo "--- Main Menu ---"
    echo "1. Actualizar Sistema"
    echo "2. Pones Bonito el Prompt"
    echo "3. Exit"
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
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
    echo "" # Add a newline for better readability
done
