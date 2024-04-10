#!/bin/bash

# Define the path to the app in Downloads and Applications directories
DOWNLOADS_APP_PATH="$HOME/Downloads/tachles.app"
APPLICATIONS_APP_PATH="/Applications/tachles.app"

# Function to print success message in green
print_success() {
    echo -e "\033[0;32m$1\033[0m" # Green
}

# Function to print error message in red
print_error() {
    echo -e "\033[0;31m$1\033[0m" # Red
}

# Check if tachles.app exists in Downloads
if [ -e "$DOWNLOADS_APP_PATH" ]; then
    print_success "Found tachles.app in Downloads. Preparing to deploy..."

    # Remove the quarantine attribute
    xattr -rd com.apple.quarantine "$DOWNLOADS_APP_PATH"
    print_success "Quarantine attribute removed."

    # Check if tachles.app already exists in Applications and delete it if it does
    if [ -e "$APPLICATIONS_APP_PATH" ]; then
        print_success "tachles.app already exists in Applications. Deleting the old version..."
        rm -rf "$APPLICATIONS_APP_PATH"
    fi

    # Move the new file from Downloads to Applications
    mv "$DOWNLOADS_APP_PATH" "/Applications/"
    print_success "tachles.app has been moved to Applications. Update was successful."

else
    print_error "tachles.app not found in Downloads. Please make sure the file is in the right location and try again."
fi
