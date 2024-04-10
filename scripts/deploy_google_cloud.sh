#!/bin/bash


cd /Users/ofirozeri/development/zion_link
# Clean flutter project and build for web
flutter clean && 
flutter build web

print_success() {
    echo -e "\033[32m$1\033[0m"
}

print_error() {
    echo -e "\033[31m$1\033[0m"
}

# If the build is successful, deploy to Google Cloud
if [ $? -eq 0 ]; then
    print_success "Build successful. Deploying to Google Cloud..."
    gcloud app deploy &&
    print_success "Deployment successful."
else
    print_error "Build failed. Deployment to Google Cloud aborted."
fi