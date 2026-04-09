#!/usr/bin/env bash
# 🐿️ Baby Kkoramji Setup Script
# Claude Code에 아기꼬람지 훅을 설치한다.
# 기존 settings.json은 초기화하지 않고, 훅 항목만 안전하게 추가한다.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_SRC="$SCRIPT_DIR/hooks/baby-kkoramji.py"
RULE_SRC="$SCRIPT_DIR/claude-rule.md"

echo "🐿️ Baby Kkoramji 설치 시작..."
echo ""

# ── 설치 모드 선택 ──────────────────────────────────────────────────────────
echo "설치 방식을 선택해주세요:"
echo "  1) 전역 설치 (~/.claude/) — 모든 프로젝트에서 동작"
echo "  2) 로컬 설치 (상위 프로젝트의 .claude/) — 현재 프로젝트에서만 동작"
echo ""
read -rp "선택 (1/2): " INSTALL_MODE

case "$INSTALL_MODE" in
  1)
    INSTALL_BASE="$HOME"
    HOOK_CMD="$HOME/.claude/hooks/baby-kkoramji.py"
    echo "→ 전역 설치 모드"
    ;;
  2)
    INSTALL_BASE="$(dirname "$SCRIPT_DIR")"
    HOOK_CMD=".claude/hooks/baby-kkoramji.py"
    echo "→ 로컬 설치 모드 (대상: $INSTALL_BASE)"
    ;;
  *)
    echo "❌ 잘못된 선택입니다. 1 또는 2를 입력해주세요."
    exit 1
    ;;
esac

HOOK_DEST="$INSTALL_BASE/.claude/hooks/baby-kkoramji.py"
RULES_DIR="$INSTALL_BASE/.claude/rules"
RULE_DEST="$RULES_DIR/baby-kkoramji.md"
SETTINGS="$INSTALL_BASE/.claude/settings.json"

echo ""

# ── 1. 훅 스크립트 복사 ──────────────────────────────────────────────────────
mkdir -p "$INSTALL_BASE/.claude/hooks"
cp "$HOOK_SRC" "$HOOK_DEST"
chmod +x "$HOOK_DEST"
echo "✅ 훅 스크립트 복사: $HOOK_DEST"

# ── 2. Claude 규칙 파일 추가 ─────────────────────────────────────────────────
mkdir -p "$RULES_DIR"
cp "$RULE_SRC" "$RULE_DEST"
echo "✅ Claude 규칙 추가: $RULE_DEST"

# ── 3. settings.json에 UserPromptSubmit 훅 추가 ──────────────────────────────
python3 - "$SETTINGS" "$HOOK_CMD" <<'PYEOF'
import json
import os
import sys

settings_path = sys.argv[1]
hook_command = sys.argv[2]

# settings.json 읽기 (없으면 빈 오브젝트)
settings = {}
if os.path.exists(settings_path):
    try:
        with open(settings_path, encoding="utf-8") as f:
            settings = json.load(f)
    except Exception as e:
        print(f"❌ settings.json 파싱 실패: {e}", file=sys.stderr)
        sys.exit(1)

# hooks 키 보장
if "hooks" not in settings:
    settings["hooks"] = {}

# UserPromptSubmit 훅 배열 보장
if "UserPromptSubmit" not in settings["hooks"]:
    settings["hooks"]["UserPromptSubmit"] = []

# 이미 동일한 커맨드가 등록되어 있으면 스킵
already_registered = any(
    any(h.get("command") == hook_command for h in entry.get("hooks", []))
    for entry in settings["hooks"]["UserPromptSubmit"]
)

if already_registered:
    print("ℹ️  아기꼬람지 훅이 이미 등록되어 있습니다.")
else:
    settings["hooks"]["UserPromptSubmit"].append({
        "hooks": [
            {
                "type": "command",
                "command": hook_command,
                "timeout": 5000
            }
        ]
    })
    with open(settings_path, "w", encoding="utf-8") as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("✅ settings.json에 UserPromptSubmit 훅 추가 완료")

PYEOF

echo ""
echo "🐿️ Baby Kkoramji 설치 완료!"
if [ "$INSTALL_MODE" = "1" ]; then
  echo "   모든 Claude Code 세션에서 아기꼬람지가 활성화됩니다."
else
  echo "   이 프로젝트의 Claude Code 세션에서 아기꼬람지가 활성화됩니다."
  echo "   대상 프로젝트: $INSTALL_BASE"
fi
