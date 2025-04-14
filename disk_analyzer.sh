#!/bin/bash

# Disk Space Analyzer - Complete Working Version
# Version: 2.2 (Fixed awk color escape issue and code cleanup)

# Configuration
THRESHOLD_PERCENT=80
TOP_FOLDERS=10
TEMP_DIRS=("/tmp" "$TEMP" "$TMP" "/c/Windows/Temp")

# Colors
RED=$(printf '\033[31m')
GREEN=$(printf '\033[32m')
YELLOW=$(printf '\033[33m')
BLUE=$(printf '\033[34m')
NC=$(printf '\033[0m')

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
    # Remove trailing slash for consistency
    target_dir="${target_dir%/}"
    echo -e "${BLUE}=== Top $TOP_FOLDERS Space-Consuming Items in $target_dir ===${NC}"

    if [ ! -d "$target_dir" ]; then
        echo -e "${RED}Error: Directory does not exist!${NC}"
        return 1
    fi

    local unix_sort="/usr/bin/sort"

    if [ -x "$unix_sort" ]; then
        # Use awk to exclude the parent directory line
        du -ah "$target_dir" 2>/dev/null | awk -v dir="$target_dir" '$2 != dir' | "$unix_sort" -rh | head -n $TOP_FOLDERS
    else
        echo -e "${RED}Error: Unix sort not found. Check Git Bash installation.${NC}"
    fi
}
# Optimized cleaning function
clean_temp_files() {
    local total_freed=0
    local cleaned_dirs=()

    echo -e "${YELLOW}=== Cleaning Temporary Files ===${NC}"

    # Updated temp directories list
    TEMP_DIRS=(
        "/tmp"                                  # Unix-style temp
        "$TEMP"                                 # Windows user temp
        "$TMP"                                  # Alternative Windows temp
        "/c/Windows/Temp"                       # System temp (critical fix)
        "/c/Users/$(whoami)/AppData/Local/Temp" # User temp
    )

    for dir in "${TEMP_DIRS[@]}"; do
        # Convert to Windows-style path for find.exe compatibility
        win_dir="$(cygpath -w "$dir" 2>/dev/null || echo "$dir")"
        
        # Check directory existence
        if [ ! -d "$dir" ]; then
            echo -e "${YELLOW}Directory $dir not found. Skipping...${NC}"
            continue
        fi

        echo -e "Cleaning in ${GREEN}$dir${NC}"

        # Calculate space before cleaning (in KB)
        space_before=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
        [ -z "$space_before" ] && space_before=0

        # Force use of Windows find.exe with admin privileges
        if command -v find.exe &>/dev/null; then
            # Run with elevated privileges for system directories
            if [[ "$dir" == "/c/Windows/Temp" ]]; then
                echo "Elevated privileges required for system temp files"
                powershell.exe -Command "Start-Process find.exe -ArgumentList '\"$win_dir\" -type f -mtime +30 -delete' -Verb RunAs"
            else
                find.exe "$win_dir" -type f \( -name "*.tmp" -o -name "*.temp" -o -name "*.log" \) -mtime +30 -delete 2>/dev/null
            fi
            
            find.exe "$win_dir" -type d -empty -delete 2>/dev/null
        else
            echo -e "${RED}find.exe not found - skipping Windows temp cleanup${NC}"
        fi

        # Calculate space after cleaning
        space_after=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
        [ -z "$space_after" ] && space_after=0

        # Calculate freed space
        freed=$((space_before - space_after))
        if [ "$freed" -gt 0 ]; then
            echo -e "Freed: ${GREEN}$((freed / 1024)) MB${NC}"
            total_freed=$((total_freed + freed))
        else
            echo "No files to clean (or permission denied)"
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
