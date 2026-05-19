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

    # --- Auto-Collect MCP ---
    echo "🔍 Scanning MCP configurations..."
    MCP_CONFIG=""
    for f in .qoder/settings.local.json .cursor/mcp.json .vscode/mcp.json mcp.json config/mcporter.json .claude/claude_desktop_config.json; do
      if [ -f "$f" ]; then
        MCP_CONFIG="$f"
        break
      fi
    done

    MCP_COUNT=0
    MCP_UNMAPPED=0
    if [ -n "$MCP_CONFIG" ]; then
        echo "   Found: $MCP_CONFIG"
        # Extract mcpServers keys using python (universally available)
        SERVERS=$(python3 -c "
import json, sys
try:
    with open('$MCP_CONFIG') as f:
        data = json.load(f)
    servers = data.get('mcpServers', {})
    for key in servers:
        print(key)
except Exception:
    pass
" 2>/dev/null || true)

        # Mapping rules (from _mcp-discovery.yaml)
        declare -A CAP_MAP
        CAP_MAP["cap.log.query"]="sls|log|logging|loki|elk|splunk|datadog"
        CAP_MAP["cap.database.query"]="db|dms|mysql|postgres|postgresql|mongo|redis|sqlite|oracle"
        CAP_MAP["cap.deploy.async"]="deploy|aone|cd-|jenkins|argocd|kubectl|k8s"
        CAP_MAP["cap.config.read"]="diamond|nacos|apollo|config-center|configcenter|consul|etcd"
        CAP_MAP["cap.diagnose.trace"]="arthas|diagnose|trace|profiler|async-profiler|jstack|perfma"
        CAP_MAP["cap.trigger.http"]="fetch|http|request|curl-mcp|rest"
        CAP_MAP["cap.trigger.browser"]="playwright|puppeteer|browser|chromium|selenium"
        CAP_MAP["cap.trigger.rpc"]="grpc|dubbo|thrift|rpc-mcp|hsf"

        BINDINGS=""
        ENABLED_CAPS=""
        UNMAPPED_LIST=""

        for server in $SERVERS; do
            server_lower=$(echo "$server" | tr '[:upper:]' '[:lower:]')
            matched=""
            for cap in "${!CAP_MAP[@]}"; do
                pattern="${CAP_MAP[$cap]}"
                if echo "$server_lower" | grep -qE "$pattern"; then
                    matched="$cap"
                    break
                fi
            done
            if [ -n "$matched" ]; then
                BINDINGS="${BINDINGS}  ${matched}: ${server}\n"
                ENABLED_CAPS="${ENABLED_CAPS}    - ${matched}\n"
                MCP_COUNT=$((MCP_COUNT + 1))
                echo "   ✅ $server → $matched"
            else
                UNMAPPED_LIST="${UNMAPPED_LIST}  # unmapped: ${server}\n"
                MCP_UNMAPPED=$((MCP_UNMAPPED + 1))
                echo "   ⚠️  $server → unmapped"
            fi
        done

        # Write MCP bindings to adaptations.yaml
        if [ -n "$BINDINGS" ]; then
            printf "\nmcp_bindings:\n%b" "$BINDINGS" >> "$WORKSPACE_DIR/adaptations.yaml"
        fi
        if [ -n "$UNMAPPED_LIST" ]; then
            printf "\n# Unmapped MCP servers (assign manually):\n%b" "$UNMAPPED_LIST" >> "$WORKSPACE_DIR/adaptations.yaml"
        fi

        # Update config.yaml: enabled_capabilities
        if [ -n "$ENABLED_CAPS" ]; then
            sed -i.bak "s/^  enabled_capabilities: \[\]/  enabled_capabilities:\n$(printf '%b' "$ENABLED_CAPS")/" "$WORKSPACE_DIR/config.yaml" 2>/dev/null || \
            sed -i '' "s/^  enabled_capabilities: \[\]/  enabled_capabilities:\n$(printf '%b' "$ENABLED_CAPS")/" "$WORKSPACE_DIR/config.yaml"
            rm -f "$WORKSPACE_DIR/config.yaml.bak"
        fi
    else
        echo "   No MCP config found, skipping."
    fi

    # --- Auto-Collect Skills ---
    echo "🌾 Scanning existing skills & pitfalls..."
    SKILL_COUNT=0
    PITFALL_COUNT=0
    SKILL_DIRS=".qoder/skills .qoder/learned-skills .cursor/rules .aone/skills .claude/commands skills docs/testing scripts/test"
    RELEVANCE_PATTERN="test|verify|validate|assert|check|coverage|regression|smoke|e2e|integration-test|unit-test|api-test|deploy-verify|bug|error|fail|pitfall|troubleshoot|hotfix|incident"
    PITFALL_PATTERN="symptom|root.cause|workaround|known.issue|gotcha|caveat|troubleshoot"

    for dir in $SKILL_DIRS; do
      if [ -d "$dir" ]; then
        find "$dir" -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.txt" \) 2>/dev/null | while read -r filepath; do
          # Check relevance
          if grep -qilE "$RELEVANCE_PATTERN" "$filepath" 2>/dev/null; then
            filename=$(basename "$filepath")
            # Classify: pitfall or skill
            if grep -qilE "$PITFALL_PATTERN" "$filepath" 2>/dev/null; then
              # Pitfall
              target="$WORKSPACE_DIR/pitfalls/$filename"
              if [ ! -f "$target" ]; then
                cp "$filepath" "$target"
                echo "   ✅ $filepath → pitfalls/$filename"
                PITFALL_COUNT=$((PITFALL_COUNT + 1))
              fi
            else
              # Skill
              target="$WORKSPACE_DIR/skills/$filename"
              if [ ! -f "$target" ]; then
                cp "$filepath" "$target"
                echo "   ✅ $filepath → skills/$filename"
                SKILL_COUNT=$((SKILL_COUNT + 1))
              fi
            fi
          fi
        done
      fi
    done

    echo ""
    echo "✅ Workspace ready:"
    echo "   $WORKSPACE_DIR/config.yaml          (edit me)"
    echo "   $WORKSPACE_DIR/adaptations.yaml     (auto-evolved)"
    echo "   $WORKSPACE_DIR/memory.md            (team preferences)"
    echo "   🔍 MCP: $MCP_COUNT bound, $MCP_UNMAPPED unmapped"
    echo "   🌾 Skills collected from project"
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
echo "👉 Next: review $WORKSPACE_DIR/config.yaml, then ask your AI: /test-sop <requirement-source>"
echo "💡 Later: /test-sop collect-mcp or /test-sop collect-skill to re-scan & organize."
