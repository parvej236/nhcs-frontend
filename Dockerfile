# Stage 1: Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Set working directory
WORKDIR /app

# Copy dependency definition
COPY pubspec.yaml pubspec.lock* ./

# Fetch dependencies
RUN flutter pub get

# Copy all source files
COPY . .

# Accept API URL build-time variable
ARG API_URL

# Build web application
RUN flutter build web --release --dart-define=API_URL=$API_URL

# Stage 2: Production environment using Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
