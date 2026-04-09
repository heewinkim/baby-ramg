#!/usr/bin/env bash
# 🐿️ Baby Kkoramji Legacy Uninstaller
# 예전 버전(anthropic SDK / claude -p 방식)의 훅, 규칙, settings 항목을 제거한다.
# 전역(~/.claude/)과 로컬(상위 프로젝트 .claude/) 모두 처리.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_BASE="$(dirname "$SCRIPT_DIR")"

echo "🐿️ Baby Kkoramji 예전 버전 제거 시작..."
echo ""

REMOVED=0

# ── 파일 제거 함수 ────────────────────────────────────────────────────────────
remove_if_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    rm "$file"
    echo "  🗑  삭제: $file"
    REMOVED=$((REMOVED + 1))
  fi
}

# ── settings.json에서 baby-kkoramji 훅 항목 제거 ──────────────────────────────
remove_hook_from_settings() {
  local settings="$1"
  if [ ! -f "$settings" ]; then
    return
  fi

  python3 - "$settings" <<'PYEOF'
import json, sys

settings_path = sys.argv[1]
with open(settings_path, encoding="utf-8") as f:
    settings = json.load(f)

hooks_list = settings.get("hooks", {}).get("UserPromptSubmit", [])
before = len(hooks_list)

filtered = [
    entry for entry in hooks_list
    if not any("baby-kkoramji" in h.get("command", "") for h in entry.get("hooks", []))
]

if len(filtered) < before:
    settings["hooks"]["UserPromptSubmit"] = filtered
    # UserPromptSubmit이 비면 키 자체 제거
    if not filtered:
        del settings["hooks"]["UserPromptSubmit"]
    # hooks가 비면 키 자체 제거
    if not settings["hooks"]:
        del settings["hooks"]
    with open(settings_path, "w", encoding="utf-8") as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"  🗑  settings.json에서 훅 항목 제거: {settings_path}")
else:
    print(f"  ℹ️  훅 항목 없음: {settings_path}")
PYEOF
}

# ── 전역 제거 (~/.claude/) ────────────────────────────────────────────────────
echo "📍 전역 (~/.claude/) 확인..."
remove_if_exists "$HOME/.claude/hooks/baby-kkoramji.py"
remove_if_exists "$HOME/.claude/rules/baby-kkoramji.md"
remove_hook_from_settings "$HOME/.claude/settings.json"
echo ""

# ── 로컬 제거 (상위 프로젝트 .claude/) ────────────────────────────────────────
echo "📍 로컬 ($PROJECT_BASE/.claude/) 확인..."
remove_if_exists "$PROJECT_BASE/.claude/hooks/baby-kkoramji.py"
remove_if_exists "$PROJECT_BASE/.claude/rules/baby-kkoramji.md"
remove_hook_from_settings "$PROJECT_BASE/.claude/settings.json"
echo ""

# ── 결과 ──────────────────────────────────────────────────────────────────────
if [ "$REMOVED" -gt 0 ]; then
  echo "✅ 예전 버전 제거 완료! (파일 ${REMOVED}개 삭제)"
else
  echo "ℹ️  제거할 파일이 없었습니다."
fi
