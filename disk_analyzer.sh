#!/bin/bash

# Disk Space Analyzer - Complete Working Version
# Version: 2.0

# Configuration
THRESHOLD_PERCENT=80
TOP_FOLDERS=10
TEMP_DIRS=("/tmp" "$TEMP" "$TMP" "/c/Windows/Temp")

# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
NC='\e[0m'

# Function to display disk usage
show_disk_usage() {
    echo -e "${BLUE}=== Disk Usage Overview ===${NC}"
    df -h | awk -v threshold=$THRESHOLD_PERCENT '
    NR==1 {print $0}
    NR>1 {
        split($5, percent, "%");
        if (percent[1] > threshold) {
            printf "'${RED}'%s'${NC}'\n", $0;
        } else {
            print $0;
        }
    }'
}

# Function to analyze folder sizes
analyze_folders() {
    local target_dir="${1:-$(pwd)}"
    
    echo -e "${BLUE}=== Top $TOP_FOLDERS Space-Consuming Items in $target_dir ===${NC}"
    
    if [ ! -d "$target_dir" ]; then
        echo -e "${RED}Error: Directory does not exist!${NC}"
        return 1
    fi

    if command -v du.exe &>/dev/null; then
        du.exe -ah "$target_dir" 2>/dev/null | sort -rh | head -n $TOP_FOLDERS | awk -F'\t' '{
            printf "%s\t%s\n", $1, $2
        }'
    else
        du -ah "$target_dir" 2>/dev/null | sort -rh | head -n $TOP_FOLDERS | awk -F'\t' '{
            printf "%s\t%s\n", $1, $2
        }'
    fi
}

# Optimized cleaning function
clean_temp_files() {
    local total_freed=0
    local cleaned_dirs=()
    
    echo -e "${YELLOW}=== Cleaning Temporary Files ===${NC}"
    
    for dir in "${TEMP_DIRS[@]}"; do
        # Skip duplicates and non-existent directories
        if [[ " ${cleaned_dirs[@]} " =~ " ${dir} " ]] || [ ! -d "$dir" ]; then
            [ ! -d "$dir" ] && echo -e "${YELLOW}Directory $dir not found. Skipping...${NC}"
            continue
        fi
        cleaned_dirs+=("$dir")
        
        echo -e "Cleaning in ${GREEN}$dir${NC}"
        
        # Calculate space before cleaning
        space_before=$(du -s "$dir" 2>/dev/null | awk '{print $1}')
        [ -z "$space_before" ] && space_before=0
        
        # Clean files older than 7 days
        if command -v find.exe &>/dev/null; then
            find.exe "$dir" -type f -mtime +7 -delete 2>/dev/null
            find.exe "$dir" -type d -empty -delete 2>/dev/null
        else
            find "$dir" -type f -mtime +7 -delete 2>/dev/null
            find "$dir" -type d -empty -delete 2>/dev/null
        fi
        
        # Calculate space after cleaning
        space_after=$(du -s "$dir" 2>/dev/null | awk '{print $1}')
        [ -z "$space_after" ] && space_after=0
        
        freed=$((space_before - space_after))
        if [ "$freed" -gt 0 ]; then
            echo -e "Freed: ${GREEN}$((freed / 1024)) MB${NC}"
            total_freed=$((total_freed + freed))
        else
            echo "No files to clean"
        fi
    done
    
    echo -e "${GREEN}=== Total Freed: $((total_freed / 1024)) MB ===${NC}"
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
