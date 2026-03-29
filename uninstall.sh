#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
SOUNDS_DIR="$CLAUDE_DIR/sounds"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "🗑️  Claude Pikmin Sound 제거 중..."

# 1. 사운드 파일 제거
if [ -d "$SOUNDS_DIR" ]; then
  rm -f "$SOUNDS_DIR"/*.mp3
  rmdir "$SOUNDS_DIR" 2>/dev/null || true
  echo "✅ 사운드 파일 제거 완료"
else
  echo "ℹ️  사운드 디렉토리가 없습니다. 건너뜁니다."
fi

# 2. settings.json에서 Stop hook 제거
if [ -f "$SETTINGS_FILE" ] && command -v jq &> /dev/null; then
  if jq -e '.hooks.Stop' "$SETTINGS_FILE" &> /dev/null; then
    # afplay + sounds 관련 hook만 필터링하여 제거
    jq '.hooks.Stop = [.hooks.Stop[] | select(.hooks[0].command | test("afplay.*sounds") | not)]' \
      "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

    # Stop 배열이 비었으면 제거
    if jq -e '.hooks.Stop | length == 0' "$SETTINGS_FILE" &> /dev/null; then
      jq 'del(.hooks.Stop)' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    fi

    # hooks 객체가 비었으면 제거
    if jq -e '.hooks | length == 0' "$SETTINGS_FILE" &> /dev/null; then
      jq 'del(.hooks)' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    fi

    echo "✅ settings.json에서 사운드 hook 제거 완료"
  else
    echo "ℹ️  Stop hook이 없습니다. 건너뜁니다."
  fi
else
  echo "⚠️  jq가 없거나 settings.json이 없습니다. 수동으로 hook을 제거해주세요."
fi

echo ""
echo "✅ 제거 완료!"
