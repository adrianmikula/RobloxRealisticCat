#!/bin/bash

# Get Started with Testing Script
# This script helps set up and verify the testing environment

echo "🚀 Getting Started with Roblox Testing"
echo "======================================"

# Check if Lune is installed
echo -n "1. Checking for Lune... "
if command -v lune &> /dev/null; then
    echo "✅ Found"
    lune --version
else
    echo "❌ Not found"
    echo ""
    echo "   To install Lune:"
    echo "   - Download from https://lune.sh"
    echo "   - Add to your PATH"
    echo "   - Or run: curl -fsSL https://github.com/lune-org/lune/releases/latest/download/lune-macos-x86_64.tar.gz | tar -xz && sudo mv lune /usr/local/bin/"
    echo ""
    read -p "   Press Enter to continue without Lune, or Ctrl+C to install it first..."
fi

# Check Node.js/npm
echo -n "2. Checking for Node.js/npm... "
if command -v npm &> /dev/null; then
    echo "✅ Found"
    npm --version
else
    echo "⚠️  Not found (optional)"
fi

# Check Wally
echo -n "3. Checking for Wally... "
if command -v wally &> /dev/null; then
    echo "✅ Found"
else
    echo "❌ Not found"
    echo ""
    echo "   To install Wally:"
    echo "   - Run: cargo install wally-cli"
    echo "   - Or download from https://wally.run"
    echo ""
    read -p "   Press Enter to continue without Wally, or Ctrl+C to install it first..."
fi

# Check project structure
echo ""
echo "4. Checking project structure..."
if [ -f "wally.toml" ]; then
    echo "   ✅ wally.toml found"
else
    echo "   ❌ wally.toml not found"
fi

if [ -f "package.json" ]; then
    echo "   ✅ package.json found"
else
    echo "   ❌ package.json not found"
fi

if [ -d "src/__tests__" ]; then
    echo "   ✅ src/__tests__ directory found"
    echo "   Test files:"
    ls -la src/__tests__/
else
    echo "   ❌ src/__tests__ directory not found"
fi

if [ -d "DevPackages" ]; then
    echo "   ✅ DevPackages directory found"
else
    echo "   ❌ DevPackages directory not found"
    echo "   Run: wally install"
fi

# Run debug test if Lune is available
if command -v lune &> /dev/null; then
    echo ""
    echo "5. Running debug test runner..."
    lune run scripts/debug-test-runner.lua
else
    echo ""
    echo "5. Skipping debug test (Lune not installed)"
fi

# Summary
echo ""
echo "🎯 Summary"
echo "=========="
echo ""
echo "To get started with testing:"
echo ""
echo "1. INSTALL LUNE (required):"
echo "   Download from https://lune.sh and add to PATH"
echo ""
echo "2. VERIFY SETUP:"
echo "   lune run scripts/debug-test-runner.lua"
echo ""
echo "3. RUN TESTS:"
echo "   Simple tests: lune run scripts/simple-test-runner.lua"
echo "   Jest tests:   lune run scripts/test-runner.lua"
echo "   npm tests:    npm test"
echo ""
echo "4. WRITE YOUR FIRST TEST:"
echo "   Create: src/__tests__/my-module.spec.lua"
echo "   See examples in src/__tests__/"
echo ""
echo "5. AUTOMATE:"
echo "   Add pre-commit hook: cp scripts/pre-commit .git/hooks/"
echo "   Set up CI/CD: See docs/testing/CLI_TESTING_GUIDE.md"
echo ""
echo "📚 Documentation:"
echo "- docs/testing/CLI_TESTING_GUIDE.md"
echo "- docs/testing/TESTING_STRATEGY.md"
echo "- docs/testing/LUNE_SETUP.md"
echo ""
echo "Happy testing! 🧪"