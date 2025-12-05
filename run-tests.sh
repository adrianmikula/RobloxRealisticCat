#!/bin/bash

# Realistic Cat Game Test Runner
# Run with: ./run-tests.sh

set -e  # Exit on error

echo "🐱 Realistic Cat Game Test Runner"
echo "================================="

# Check if Lune is installed
if ! command -v lune &> /dev/null; then
    echo "❌ Lune is not installed. Please install it from:"
    echo "   https://lune.sh"
    echo ""
    echo "Quick install:"
    echo "  curl -fsSL https://github.com/lune-org/lune/releases/latest/download/lune-linux-x86_64.tar.gz | tar -xz"
    echo "  sudo mv lune /usr/local/bin/"
    exit 1
fi

echo "✅ Lune version: $(lune --version)"

# Check if Wally packages are installed
if [ ! -d "Packages" ] || [ ! -d "DevPackages" ]; then
    echo "📦 Installing Wally packages..."
    wally install
fi

echo "✅ Dependencies checked"

# Run tests
echo ""
echo "🚀 Running tests..."
echo "------------------"

lune run scripts/test-runner.lua

EXIT_CODE=$?

echo ""
echo "================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Tests failed with exit code: $EXIT_CODE"
fi

exit $EXIT_CODE