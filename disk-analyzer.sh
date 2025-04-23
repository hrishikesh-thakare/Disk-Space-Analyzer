#!/bin/bash

# Disk Space Analyzer 

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
NC="\033[0m"
THRESHOLD_PERCENT=90

# Function to display disk usage
show_disk_usage() {
    echo -e "${BLUE}=== Disk Usage Overview ===${NC}"
    df -h | awk -v threshold=$THRESHOLD_PERCENT -v RED="$RED" -v NC="$NC" '
    NR==1 {print $0}
    NR>1 {
        split($5, percent, "%");
        if (percent[1] > threshold) {
            printf "%s%s%s\n", RED, $0, NC;
        } else {
            print $0;
        }
    }'
}

# Function to analyze folder sizes
analyze_folders() {
    local target_dir="${1:-$(pwd)}"
    echo -e "${BLUE}=== Top 10 Space-Consuming Items in $target_dir ===${NC}"

    if [ ! -d "$target_dir" ]; then
        echo -e "${RED}Error: Directory does not exist!${NC}"
        return 1
    fi

    du -ah --max-depth=1 "$target_dir" | awk -v dir="$target_dir" '$2 != dir' | sort -rh | head -n 10
}

# Function to remove all temporary files from the temporary directory
clean_temp_files() {
    echo -e "${YELLOW}=== Cleaning Temporary Files ===${NC}"
    /usr/bin/find /c/Windows/Temp/ -type f -exec rm -f {} \;
    /usr/bin/find /c/Windows/Temp/ -type d -empty -delete
    echo "Temporary Files Deleted"
}

# Main menu
main_menu() {
    while true; do
        echo -e "${BLUE}=== Disk Space Analyzer ===${NC}"
        echo "1. Show Disk Usage"
        echo "2. Analyze Folder Sizes (current directory)"
        echo "3. Analyze Specific Folder"
        echo "4. Clean Temporary Files"
        echo "5. Exit"
        read -p "Choose an option: " option

        case $option in
            1)
                show_disk_usage
                ;;
            2)
                analyze_folders "$(pwd)"
                ;;
            3)
                read -p "Enter folder path: " custom_dir
                analyze_folders "$custom_dir"
                ;;
            4)
                clean_temp_files
                ;;
            5)
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                ;;
        esac

        read -p "Press Enter to continue..."
        clear
    done
}

# Start the script
main_menu
