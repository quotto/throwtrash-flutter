FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    optipng \
    ca-certificates \
    gnupg \
    openssh-client \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev \
    locales \
    tzdata \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create a non-root user
RUN groupadd -g 1000 developer && \
    useradd -u 1000 -g 1000 -s /bin/bash -m developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer

# Install Dart SDK
RUN apt-get update && apt-get install -y apt-transport-https && \
    curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    curl -fsSL https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list && \
    apt-get update && \
    apt-get install -y dart && \
    rm -rf /var/lib/apt/lists/*

# Set Dart path
ENV PATH="$PATH:/usr/lib/dart/bin:/root/.pub-cache/bin"

USER developer
WORKDIR /home/developer

# Ensure user's PATH includes dart
ENV PATH="$PATH:/usr/lib/dart/bin:/home/developer/.pub-cache/bin"

# Install FVM
RUN dart pub global activate fvm

# Install Flutter using FVM
RUN fvm install 3.24.3 && \
    fvm global 3.24.3 && \
    fvm use 3.24.3 --force

# Set up PATH to include Flutter and FVM
ENV PATH="/home/developer/fvm/default/bin:/home/developer/.pub-cache/bin:$PATH"

# Pre-download Flutter development binaries
RUN flutter precache && \
    flutter config --no-analytics && \
    flutter doctor

# Install required CLI tools
RUN dart pub global activate flutterfire_cli

WORKDIR /workspaces/throwtrash-flutter