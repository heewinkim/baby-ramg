#!/usr/bin/env bash
# 🐿️ Baby Kkoramji Setup Script
# Claude Code에 아기꼬람지 훅을 설치한다.
# 기존 settings.json은 초기화하지 않고, 훅 항목만 안전하게 추가한다.

set -e

HOOK_SRC="$(cd "$(dirname "$0")" && pwd)/hooks/baby-kkoramji.py"
HOOK_DEST="$HOME/.claude/hooks/baby-kkoramji.py"
SETTINGS="$HOME/.claude/settings.json"
RULES_DIR="$HOME/.claude/rules"
RULE_DEST="$RULES_DIR/baby-kkoramji.md"
RULE_SRC="$(cd "$(dirname "$0")" && pwd)/claude-rule.md"

echo "🐿️ Baby Kkoramji 설치 시작..."

# ── 1. 훅 스크립트 복사 ──────────────────────────────────────────────────────
mkdir -p "$HOME/.claude/hooks"
cp "$HOOK_SRC" "$HOOK_DEST"
chmod +x "$HOOK_DEST"
echo "✅ 훅 스크립트 복사: $HOOK_DEST"

# ── 2. Claude 규칙 파일 추가 ─────────────────────────────────────────────────
mkdir -p "$RULES_DIR"
cp "$RULE_SRC" "$RULE_DEST"
echo "✅ Claude 규칙 추가: $RULE_DEST"

# ── 3. settings.json에 UserPromptSubmit 훅 추가 ──────────────────────────────
python3 - <<'PYEOF'
import json
import os
import sys

settings_path = os.path.expanduser("~/.claude/settings.json")
hook_command = "~/.claude/hooks/baby-kkoramji.py"

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
                "timeout": 10000
            }
        ]
    })
    with open(settings_path, "w", encoding="utf-8") as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("✅ settings.json에 UserPromptSubmit 훅 추가 완료")

PYEOF

# ── 4. 환경 확인 ─────────────────────────────────────────────────────────────
echo ""
echo "🔍 환경 확인..."
python3 -c "import anthropic; print(f'✅ anthropic 패키지: {anthropic.__version__}')" 2>/dev/null \
  || echo "⚠️  anthropic 패키지 없음 → pip install anthropic"

if [ -z "$ANTHROPIC_API_KEY" ]; then
  echo "⚠️  ANTHROPIC_API_KEY 환경변수가 설정되지 않았습니다."
  echo "    ~/.zshrc 또는 ~/.bashrc에 추가하세요:"
  echo "    export ANTHROPIC_API_KEY=your_api_key"
else
  echo "✅ ANTHROPIC_API_KEY 설정됨"
fi

echo ""
echo "🐿️ Baby Kkoramji 설치 완료!"
echo "   다음 Claude Code 세션부터 아기꼬람지가 활성화됩니다."
