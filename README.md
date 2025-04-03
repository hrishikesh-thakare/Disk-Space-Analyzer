# Disk Space Analyzer  

## Overview  
Disk Space Analyzer is a **Bash script** that helps monitor disk usage, analyze large folders, and clean temporary files. It provides an interactive menu for better disk space management.  

## Features  
✅ **Show Disk Usage** – Displays disk usage with color-coded alerts  
✅ **Analyze Folder Sizes** – Lists top 10 space-consuming folders  
✅ **Analyze Specific Folder** – Allows users to inspect a specific folder  
✅ **Clean Temporary Files** – Deletes temp files older than 7 days  
✅ **Works on Linux & Windows** (via Git Bash or WSL)  

## Installation  

### 1. Clone the Repository  
```bash
git clone https://github.com/hrishikesh-thakare/disk-space-analyzer.git
cd disk-space-analyzer

# Make executable if permissions are lost during transfer
chmod +x disk-analyzer.sh

# Run normally
./disk-analyzer.sh

#To customize the script settings, open it with Nano:
nano disk-analyzer.sh

