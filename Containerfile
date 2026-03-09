FROM quay.io/almalinuxorg/10-base:10

# Install Nginx
RUN dnf install -y nginx && \
    dnf clean all

# Expose port 80
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]