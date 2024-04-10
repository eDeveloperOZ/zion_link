# Use the official nginx image as a parent image
FROM nginx:latest

# Copy the build output to replace the default nginx contents.
COPY nginx.conf /etc/nginx/nginx.conf
COPY build/web /usr/share/nginx/html

# Expose port 80 to the outside once the container has launched
EXPOSE 8080
