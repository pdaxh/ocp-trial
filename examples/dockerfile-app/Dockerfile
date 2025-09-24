# Multi-stage Dockerfile for nginx application
FROM nginx:1.21-alpine AS base

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static content
COPY html/ /usr/share/nginx/html/

# Use existing nginx user (already exists in nginx:alpine)
# Just ensure it has the right permissions

# Set proper permissions
RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    chown -R nginx:nginx /usr/share/nginx/html

# Switch to non-root user
USER nginx

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
