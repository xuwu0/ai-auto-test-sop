#!/usr/bin/env bash
set -e

REPO="ai-auto-test-sop"
TARGET_DIR=".test-sop"
REPO_URL="https://github.com/xuwu0/ai-auto-test-sop.git"
CONFIG_FILE="test-config.yaml"

echo "🤖 Initializing AI Auto Test SOP..."

# 1. Check environment
if ! command -v git &> /dev/null; then
    echo "❌ git is required to run this installer."
    exit 1
fi

# 2. Install or Update
if [ -d "$TARGET_DIR/.git" ]; then
    echo "🔄 Found existing installation, updating..."
    cd "$TARGET_DIR"
    git pull origin main
    cd ..
else
    echo "📦 Downloading latest release..."
    git clone "$REPO_URL" "$TARGET_DIR"
    # Clean up git metadata for the user
    rm -rf "$TARGET_DIR/.git" "$TARGET_DIR/.github"
fi

# 3. Initialize Config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "📝 Generating default configuration: $CONFIG_FILE"
    cp "$TARGET_DIR/config/test-config-template.yaml" "$CONFIG_FILE"
    echo "✅ Please edit $CONFIG_FILE to match your project stack."
else
    echo "✅ Configuration $CONFIG_FILE already exists, skipping."
fi

echo "🎉 Installation complete! You can now ask your AI to run tests using the SOP in .test-sop/"
