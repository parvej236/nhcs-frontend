# Stage 1: Build stage
FROM debian:bookworm-slim AS build-env

# Install essential dependencies
RUN apt-get update && apt-get install -y \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa \
  wget \
  && rm -rf /var/lib/apt/lists/*

# Clone Flutter Stable
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable --depth 1

# Setup path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run doctor and enable web
RUN flutter doctor -v
RUN flutter config --enable-web

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
