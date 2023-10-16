#!/usr/bin/bash
#
# SillyTavern Launcher Script v0.0.1
# Created by: Deffcolony
#
# Description:
# This script installs SillyTavern and/or Extras to your Linux system.
#
# Usage:
# chmod +x st-launcher.sh && ./st-launcher.sh
#
# In automated environments, you may want to run as root.
# If using curl, we recommend using the -fsSL flags.
#
# This script is intended for use on Linux systems. Please
# report any issues or bugs on the GitHub repository.
#
# GitHub: https://github.com/SillyTavern/SillyTavern-Launcher
# Issues: https://github.com/SillyTavern/SillyTavern-Launcher/issues
# ----------------------------------------------------------
# Note: Modify the script as needed to fit your requirements.
# ----------------------------------------------------------

echo -e "\033]0;SillyTavern Launcher\007"

# ANSI Escape Code for Colors
reset="\033[0m"
white_fg_strong="\033[90m"
red_fg_strong="\033[91m"
green_fg_strong="\033[92m"
yellow_fg_strong="\033[93m"
blue_fg_strong="\033[94m"
magenta_fg_strong="\033[95m"
cyan_fg_strong="\033[96m"

# Normal Background Colors
red_bg="\033[41m"
blue_bg="\033[44m"

# Environment Variables (TOOLBOX 7-Zip)
zip7version="7z2301-x64"
zip7_install_path="/usr/local/bin"

# Environment Variables (TOOLBOX FFmpeg)
ffmpeg_url="https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
ffdownload_path="/tmp/ffmpeg.7z"
ffextract_path="/opt/ffmpeg"
bin_path="$ffextract_path/bin"

# Environment Variables (TOOLBOX Node.js)
node_installer_path="/tmp/NodejsInstaller.sh"

# Environment Variables (TOOLBOX Install Extras)
miniconda_path="$HOME/miniconda3"

# Define variables to track module status
modules_path="$HOME/modules.txt"
coqui_trigger="false"
rvc_trigger="false"
talkinghead_trigger="false"
caption_trigger="false"
summarize_trigger="false"

# Function to install Git
install_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${yellow_fg_strong}[WARN] Git is not installed on this system.${reset}"

        if command -v apt-get &>/dev/null; then
            # Debian/Ubuntu-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using apt..."
            sudo apt-get update
            sudo apt-get install -y git
        elif command -v yum &>/dev/null; then
            # Red Hat/Fedora-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using yum..."
            sudo yum install -y git
        elif command -v apk &>/dev/null; then
            # Alpine Linux-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using apk..."
            sudo apk add git
        elif command -v pacman &>/dev/null; then
            # Arch Linux-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using pacman..."
            sudo pacman -S --noconfirm git
        elif command -v emerge &>/dev/null; then
            # Gentoo Linux-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using emerge..."
            sudo emerge --ask dev-vcs/git
        else
            echo -e "${red_fg_strong}[ERROR] Unsupported Linux distribution.${reset}"
            exit 1
        fi

        echo -e "${green_fg_strong}Git is installed.${reset}"
    else
        echo -e "${blue_fg_strong}[INFO] Git is already installed.${reset}"
    fi
}

# Change the current directory to 'sillytavern' folder
cd "SillyTavern" || exit 1

# Check for updates
git fetch origin

update_status="Up to Date"
current_branch="$(git branch --show-current)"

# Check for updates
if [[ "$(git rev-list HEAD...origin/$current_branch)" ]]; then
  update_status="Update Available"
fi

# Function for the home
home() {
    clear
    echo -e "${blue_fg_strong}/ Home${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Start SillyTavern"
    echo "2. Start SillyTavern + Extras"
    echo "3. Update"
    echo "4. Backup"
    echo "5. Switch branch"
    echo "6. Toolbox"
    echo "7. Exit"

    echo "======== VERSION STATUS ========"
    echo "SillyTavern branch: $current_branch"
    echo "Update Status: $update_status"
    echo "================================"

    read -p "Choose Your Destiny (default is 1): " choice

    # Default to choice 1 if no input is provided
    if [ -z "$choice" ]; then
      choice=1
    fi

    # home - Backend
    if [ "$choice" = "1" ]; then
        start_sillytavern
    elif [ "$choice" = "2" ]; then
        start_sillytavern_with_extras
    elif [ "$choice" = "3" ]; then
        update
    elif [ "$choice" = "4" ]; then
        backup_menu
    elif [ "$choice" = "5" ]; then
        switch_branch_menu
    elif [ "$choice" = "6" ]; then
        toolbox
    elif [ "$choice" = "7" ]; then
        exit
    else
        echo -e "${yellow_fg_strong}WARNING: Invalid number. Please insert a valid number.${reset}"
        read -p "Press Enter to continue..."
        home
    fi
}

# Function to check if Node.js is installed
check_nodejs() {
    node --version > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${red_fg_strong}[ERROR] node command not found in PATH${reset}"
        echo -e "${red_bg}Please make sure Node.js is installed and added to your PATH.${reset}"
        echo -e "${blue_bg}To install Node.js, go to Toolbox${reset}"
        read -p "Press Enter to continue..."
        home
    fi
}

# Function to start SillyTavern
start_sillytavern() {
    check_nodejs
    echo -e "${blue_fg_strong}[INFO]${reset} SillyTavern has been launched."
    cd "$(dirname "$0")/SillyTavern" || exit 1
    start cmd /k start.bat
    home
}

# Function to start SillyTavern with Extras
start_sillytavern_with_extras() {
    check_nodejs
    echo -e "${blue_fg_strong}[INFO]${reset} SillyTavern has been launched."
    cd "$(dirname "$0")/SillyTavern" || exit 1
    start cmd /k start.bat

    # Run conda activate from the Miniconda installation
    source "$miniconda_path/Scripts/activate"

    # Activate the sillytavernextras environment
    conda activate sillytavernextras

    # Start SillyTavern Extras with desired configurations
    echo -e "${blue_fg_strong}[INFO]${reset} Extras has been launched."
    cd "$(dirname "$0")/SillyTavern-extras" || exit 1
    start cmd /k python server.py --coqui-gpu --rvc-save-file --cuda-device=0 --max-content-length=1000 --enable-modules=talkinghead,chromadb,caption,summarize,rvc,coqui-tts
    home
}

# Function to update
update() {
    echo "Updating..."
    cd "$(dirname "$0")/SillyTavern" || exit 1

    # Check if Git is installed
    if git --version > /dev/null 2>&1; then
        call git pull --rebase --autostash
        if [ $? -ne 0 ]; then
            # In case there are errors while updating
            echo "There were errors while updating. Please download the latest version manually."
        fi
    else
        echo -e "${red_fg_strong}[ERROR] git command not found in PATH. Skipping update.${reset}"
        echo -e "${red_bg}Please make sure Git is installed and added to your PATH.${reset}"
        echo -e "${blue_bg}To install Git, go to Toolbox.${reset}"
    fi

    read -p "Press Enter to continue..."
    home
}


create_backup() {
    # Define the backup file name with a formatted date and time
    formatted_date=$(date +'%Y-%m-%d_%H%M')
    backup_file="backups/backup_$formatted_date.tar.gz"

    # Create the backup using tar
    tar -czvf "$backup_file" \
        "public/assets/" \
        "public/Backgrounds/" \
        "public/Characters/" \
        "public/Chats/" \
        "public/context/" \
        "public/Group chats/" \
        "public/Groups/" \
        "public/instruct/" \
        "public/KoboldAI Settings/" \
        "public/movingUI/" \
        "public/NovelAI Settings/" \
        "public/OpenAI Settings/" \
        "public/QuickReplies/" \
        "public/TextGen Settings/" \
        "public/themes/" \
        "public/User Avatars/" \
        "public/user/" \
        "public/worlds/" \
        "public/settings.json" \
        "secrets.json"

    echo -e "${green_fg_strong}Backup created successfully!${reset}"

    read -p "Press Enter to continue..."
    backup_menu
}


restore_backup() {
    # List available backups
    echo "List of available backups:"
    echo "========================"
    
    backup_count=0
    backup_files=()
    
    for file in backups/backup_*.tar.gz; do
        backup_count=$((backup_count + 1))
        backup_files+=("$file")
        echo "$backup_count. ${cyan_fg_strong}$(basename "$file")${reset}"
    done
    
    echo "========================"
    read -p "Enter the number of the backup to restore: " restore_choice
    
    if [ "$restore_choice" -ge 1 ] && [ "$restore_choice" -le "$backup_count" ]; then
        selected_backup="${backup_files[restore_choice - 1]}"
        echo "Restoring backup $selected_backup..."
        
        # Extract the contents of the backup to a temporary directory
        temp_dir=$(mktemp -d)
        tar -xzvf "$selected_backup" -C "$temp_dir"
        
        # Copy the restored files to the appropriate location
        rsync -av "$temp_dir/public/" "public/"
        
        # Clean up the temporary directory
        rm -r "$temp_dir"
        
        echo -e "${green_fg_strong}$selected_backup restored successfully.${reset}"
    else
        echo -e "${yellow_fg_strong}WARNING: Invalid backup number. Please insert a valid number.${reset}"
    fi
    
    read -p "Press Enter to continue..."
    backup_menu
}

# Function for backup
backup_menu() {
    clear
    echo -e "${blue_fg_strong}/ Home / Backup${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Create Backup"
    echo "2. Restore Backup"
    echo "3. Back to Home"

    read -p "Choose Your Destiny: " backup_choice

    # Backup menu - Backend
    if [ "$backup_choice" = "1" ]; then
        create_backup
    elif [ "$backup_choice" = "2" ]; then
        restore_backup
    elif [ "$backup_choice" = "3" ]; then
        home
    else
        echo -e "${yellow_fg_strong}WARNING: Invalid number. Please insert a valid number.${reset}"
        read -p "Press Enter to continue..."
        backup_menu
    fi
}



# Function to switch to the Release branch in SillyTavern
switch_release_st() {
    echo -e "${blue_fg_strong}[INFO]${reset} Switching to release branch..."
    git switch release
    read -p "Press Enter to continue..."
    switch_branch_menu
}

# Function to switch to the Staging branch in SillyTavern
switch_staging_st() {
    echo -e "${blue_fg_strong}[INFO]${reset} Switching to staging branch..."
    git switch staging
    read -p "Press Enter to continue..."
    switch_branch_menu
}

# Function for switching branches
switch_branch_menu() {
    clear
    echo -e "${blue_fg_strong}/ Home / Switch Branch${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Switch to Release - SillyTavern"
    echo "2. Switch to Staging - SillyTavern"
    echo "3. Back to Home"

    current_branch=$(git branch --show-current)
    echo "======== VERSION STATUS ========"
    echo "SillyTavern branch: ${cyan_fg_strong}$current_branch${reset}"
    echo "Extras branch: ${cyan_fg_strong}$current_branch${reset}"
    echo "================================"

    read -p "Choose Your Destiny: " branch_choice

    # Home Menu - Backend
    if [ "$branch_choice" = "1" ]; then
        switch_release_st
    elif [ "$branch_choice" = "2" ]; then
        switch_staging_st
    elif [ "$branch_choice" = "3" ]; then
        home
    else
        echo -e "${yellow_fg_strong}WARNING: Invalid number. Please insert a valid number.${reset}"
        read -p "Press Enter to continue..."
        switch_branch_menu
    fi
}

# Function to edit environment variables
editenvironment() {
    # Open the environment variables file for editing
    if [ -f ~/.bashrc ]; then
        # Use your preferred text editor (e.g., nano, vim, or gedit)
        nano ~/.bashrc
    else
        echo "Environment file not found. Create or specify the correct file path."
    fi

    # Provide instructions to the user
    echo "Edit your environment variables. Save and exit the editor when done."

    # Optionally, ask the user to reload the environment
    read -p "Do you want to reload the environment? (Y/N): " reload
    if [ "$reload" = "Y" ] || [ "$reload" = "y" ]; then
        source ~/.bashrc  # Reload the environment (may vary based on your shell)
        echo "Environment reloaded."
    fi
}

# Function to reinstall SillyTavern
reinstallsillytavern() {
    local script_name=$(basename "$0")
    local excluded_folders="backups"
    local excluded_files="$script_name"

    echo
    echo -e "${red_bg}╔════ DANGER ZONE ═══════════════════════════════════════════════════════════════╗${reset}"
    echo -e "${red_bg}║ WARNING: This will delete all data in the current branch except the Backups.   ║${reset}"
    echo -e "${red_bg}║ If you want to keep any data, make sure to create a backup before proceeding.  ║${reset}"
    echo -e "${red_bg}╚════════════════════════════════════════════════════════════════════════════════╝${reset}"
    echo
    echo -n "Are you sure you want to proceed? [Y/N]: "
    read confirmation

    if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
        cd "$PWD/SillyTavern"

        # Remove non-excluded folders
        for dir in *; do
            exclude_folder=false
            for excluded_folder in $excluded_folders; do
                if [ "$dir" = "$excluded_folder" ]; then
                    exclude_folder=true
                    break
                fi
            done
            if [ "$exclude_folder" = "false" ]; then
                rm -r "$dir" 2>/dev/null
            fi
        done

        # Remove non-excluded files
        for file in *; do
            exclude_file=false
            for excluded_file in $excluded_files; do
                if [ "$file" = "$excluded_file" ]; then
                    exclude_file=true
                    break
                fi
            done
            if [ "$exclude_file" = "false" ]; then
                rm -f "$file" 2>/dev/null
            fi
        done

        # Clone repo into a temporary folder
        git clone https://github.com/SillyTavern/SillyTavern.git "/tmp/SillyTavern-TEMP"

        # Move the contents of the temporary folder to the current directory
        cp -r /tmp/SillyTavern-TEMP/* .

        # Clean up the temporary folder
        rm -r /tmp/SillyTavern-TEMP

        echo -e "${green_fg_strong}SillyTavern reinstalled successfully!${reset}"
    else
        echo "Reinstall canceled."
    fi

    pause
    toolbox
}

# Function to reinstall SillyTavern Extras
reinstallextras() {
    local script_name=$(basename "$0")
    local excluded_folders="backups"
    local excluded_files="$script_name"

    echo
    echo -e "${red_bg}╔════ DANGER ZONE ═══════════════════════════════════════════════════════════════════╗${reset}"
    echo -e "${red_bg}║ WARNING: This will delete all data in Sillytavern-extras                           ║${reset}"
    echo -e "${red_bg}║ If you want to keep any data, make sure to create a backup before proceeding.      ║${reset}"
    echo -e "${red_bg}╚════════════════════════════════════════════════════════════════════════════════════╝${reset}"
    echo
    echo -n "Are you sure you want to proceed? [Y/N]: "
    read confirmation

    if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
        cd "$PWD/SillyTavern-extras"

        # Remove non-excluded folders
        for dir in *; do
            exclude_folder=false
            for excluded_folder in $excluded_folders; do
                if [ "$dir" = "$excluded_folder" ]; then
                    exclude_folder=true
                    break
                fi
            done
            if [ "$exclude_folder" = "false" ]; then
                rm -r "$dir" 2>/dev/null
            fi
        done

        # Remove non-excluded files
        for file in *; do
            exclude_file=false
            for excluded_file in $excluded_files; do
                if [ "$file" = "$excluded_file" ]; then
                    exclude_file=true
                    break
                fi
            done
            if [ "$exclude_file" = "false" ]; then
                rm -f "$file" 2>/dev/null
            fi
        done

        # Clone the SillyTavern Extras repository
        git clone https://github.com/SillyTavern/SillyTavern-extras

        echo -e "${green_fg_strong}SillyTavern Extras${reset}"
        echo "---------------------------------------------------------------"
        echo -e "${blue_fg_strong}[INFO]${reset} Installing SillyTavern Extras..."
        echo "--------------------------------"
        echo -e "${cyan_fg_strong}This may take a while. Please be patient.${reset}"

        # Activate the Miniconda environment
        source "$miniconda_path/Scripts/activate"

        # Create a Conda environment named sillytavernextras
        conda create -n sillytavernextras -y

        # Activate the sillytavernextras environment
        conda activate sillytavernextras

        # Install Python 3.11 and Git in the sillytavernextras environment
        conda install python=3.11 git -y

        # Clone the SillyTavern Extras repository
        git clone https://github.com/SillyTavern/SillyTavern-extras

        # Navigate to the SillyTavern-extras directory
        cd SillyTavern-extras

        # Install Python dependencies from requirements files
        pip install -r requirements-complete.txt
        pip install -r requirements-rvc.txt

        echo -e "${green_fg_strong}SillyTavern Extras have been successfully reinstalled.${reset}"
    else
        echo "Reinstall canceled."
    fi
    pause
    toolbox
}

toolbox() {
    clear
    echo -e "${blue_fg_strong}/ Home / Toolbox${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Install 7-Zip"
    echo "2. Install FFmpeg"
    echo "3. Install Node.js"
    echo "4. Edit Environment"
    echo "5. Edit Extras Modules"
    echo "6. Reinstall SillyTavern"
    echo "7. Reinstall Extras"
    echo "8. Back to Home"

    read -p "Choose Your Destiny: " toolbox_choice

    case $toolbox_choice in
        1) install7zip ;;
        2) installffmpeg ;;
        3) installnodejs ;;
        4) editenvironment ;;
        5) editextrasmodules ;;
        6) reinstallsillytavern ;;
        7) reinstallextras ;;
        8) home ;;
        *) echo -e "${yellow_fg_strong}WARNING: Invalid number. Please insert a valid number.${reset}"
           read -p "Press Enter to continue..."
           toolbox ;;
    esac
}



# Detect the package manager and execute the appropriate installation
if command -v apt-get &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Debian/Ubuntu-based system.${reset}"
    read -p "Press Enter to continue..."
    # Debian/Ubuntu
    install_git
    install_nodejs_npm
    home
elif command -v yum &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Red Hat/Fedora-based system.${reset}"
    # Red Hat/Fedora
    install_git
    install_nodejs_npm
    home
elif command -v apk &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Alpine Linux-based system.${reset}"
    # Alpine Linux
    install_git
    install_nodejs_npm
    home
elif command -v pacman &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Arch Linux-based system.${reset}"
    # Arch Linux
    install_git
    install_nodejs_npm
    home
elif command -v emerge &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Gentoo Linux-based system. Now you are the real CHAD${reset}"
    # Gentoo Linux
    install_git
    install_nodejs_npm
    home
else
    echo -e "${red_fg_strong}[ERROR] Unsupported package manager. Cannot detect Linux distribution.${reset}"
    exit 1
fi