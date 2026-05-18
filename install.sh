#!/usr/bin/env bash
set -e

REPO="ai-auto-test-sop"
TARGET_DIR=".test-sop"
REPO_URL="https://github.com/xuwu0/ai-auto-test-sop.git"
WORKSPACE_DIR=".test-workspace"
LANG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang|-l)
      LANG="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "🤖 Initializing AI Auto Test SOP..."

# 1. Check environment
if ! command -v git &> /dev/null; then
    echo "❌ git is required to run this installer."
    exit 1
fi

# 2. Install or Update framework
if [ -d "$TARGET_DIR/.git" ]; then
    echo "🔄 Found existing framework, updating..."
    cd "$TARGET_DIR"
    git pull origin main
    cd ..
else
    echo "📦 Downloading latest framework..."
    git clone "$REPO_URL" "$TARGET_DIR"
    rm -rf "$TARGET_DIR/.git" "$TARGET_DIR/.github"
fi

# 3. Resolve language
if [ -z "$LANG" ]; then
    echo ""
    echo "Choose language / 选择语言:"
    echo "  [en] English (default)"
    echo "  [zh] 中文"
    printf "> "
    read -r LANG_INPUT
    case "$LANG_INPUT" in
      zh|ZH|cn|CN) LANG="zh" ;;
      *) LANG="en" ;;
    esac
fi

# Validate language value
case "$LANG" in
  en|zh) ;;
  *) echo "❌ Invalid language: $LANG. Supported: en, zh."; exit 1 ;;
esac

echo "🌐 Language: $LANG"

# 4. Bootstrap workspace (project-side accumulation directory)
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "🆕 Bootstrapping workspace at $WORKSPACE_DIR/ ..."
    mkdir -p "$WORKSPACE_DIR/skills"
    mkdir -p "$WORKSPACE_DIR/pitfalls"
    mkdir -p "$WORKSPACE_DIR/runs"
    mkdir -p "$WORKSPACE_DIR/proposals"

    # Seed config from templates (inject language)
    sed "s/^language: en$/language: $LANG/" "$TARGET_DIR/config/test-config-template.yaml" > "$WORKSPACE_DIR/config.yaml"
    cp "$TARGET_DIR/config/adaptations-template.yaml" "$WORKSPACE_DIR/adaptations.yaml"
    cp "$TARGET_DIR/config/workspace-gitignore-template" "$WORKSPACE_DIR/.gitignore"

    # Seed memory.md placeholder
    cat > "$WORKSPACE_DIR/memory.md" <<'EOF'
# Project Memory

> Team preferences, project context, and lessons learned. Edited by humans and AI.

## Project Context
- (Describe the project briefly here.)

## Team Preferences
- (e.g., naming conventions, must-run hooks, etc.)

## Lessons Learned
- (Auto-appended by AI's review-cycle.)
EOF

    echo "✅ Workspace ready:"
    echo "   $WORKSPACE_DIR/config.yaml          (edit me)"
    echo "   $WORKSPACE_DIR/adaptations.yaml     (auto-evolved)"
    echo "   $WORKSPACE_DIR/memory.md            (team preferences)"
    echo "   $WORKSPACE_DIR/skills/              (success workflows)"
    echo "   $WORKSPACE_DIR/pitfalls/            (project pitfalls)"
    echo "   $WORKSPACE_DIR/runs/                (per-requirement outputs)"
    echo "   $WORKSPACE_DIR/proposals/           (upstream-candidate sediments)"
else
    echo "✅ Workspace $WORKSPACE_DIR/ already exists, skipping bootstrap."
fi

# 5. Copy language-matched INSTRUCTIONS to project root
if [ "$LANG" = "zh" ]; then
    cp "$TARGET_DIR/INSTRUCTIONS_CN.md" ./INSTRUCTIONS.md
    echo "📝 Copied INSTRUCTIONS_CN.md → ./INSTRUCTIONS.md"
else
    cp "$TARGET_DIR/INSTRUCTIONS.md" ./INSTRUCTIONS.md
    echo "📝 Copied INSTRUCTIONS.md → ./INSTRUCTIONS.md"
fi

echo ""
echo "🎉 Installation complete!"
echo "👉 Next: edit $WORKSPACE_DIR/config.yaml, then ask your AI: /test-sop <requirement-source>"
