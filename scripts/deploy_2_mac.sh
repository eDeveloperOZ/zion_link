#!/bin/bash

# Define the path to the app in Downloads and Applications directories
DOWNLOADS_APP_PATH="$HOME/Downloads/zion_link.app"
APPLICATIONS_APP_PATH="/Applications/zion_link.app"

# Function to print success message in green
print_success() {
    echo -e "\033[0;32m$1\033[0m" # Green
}

# Function to print error message in red
print_error() {
    echo -e "\033[0;31m$1\033[0m" # Red
}

# Check if zion_link.app exists in Downloads
if [ -e "$DOWNLOADS_APP_PATH" ]; then
    print_success "Found zion_link.app in Downloads. Preparing to deploy..."

    # Remove the quarantine attribute
    xattr -rd com.apple.quarantine "$DOWNLOADS_APP_PATH"
    print_success "Quarantine attribute removed."

    # Check if zion_link.app already exists in Applications and delete it if it does
    if [ -e "$APPLICATIONS_APP_PATH" ]; then
        print_success "zion_link.app already exists in Applications. Deleting the old version..."
        rm -rf "$APPLICATIONS_APP_PATH"
    fi

    # Move the new file from Downloads to Applications
    mv "$DOWNLOADS_APP_PATH" "/Applications/"
    print_success "zion_link.app has been moved to Applications. Update was successful."

else
    print_error "zion_link.app not found in Downloads. Please make sure the file is in the right location and try again."
fi
