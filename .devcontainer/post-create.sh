#!/bin/bash

# Setup Flutter project
cd /workspaces/throwtrash-flutter

# Ensure FVM is set up for this project
fvm use 3.24.3 --force

# Run flutter pub get to fetch dependencies
flutter pub get

# Set proper permissions
chmod -R 777 .

echo "Flutter development environment is ready!"