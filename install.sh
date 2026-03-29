#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SOUNDS_DIR="$CLAUDE_DIR/sounds"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "🌱 Claude Pikmin Sound 설치 중..."

# 1. sounds 디렉토리 생성 및 파일 복사
mkdir -p "$SOUNDS_DIR"
cp "$SCRIPT_DIR"/sounds/*.mp3 "$SOUNDS_DIR/"
echo "✅ 사운드 파일 복사 완료 → $SOUNDS_DIR"

# 2. settings.json에 Stop hook 추가
HOOK_COMMAND='f=(~/.claude/sounds/*.mp3); afplay "${f[RANDOM % ${#f[@]}]}" &'

if [ ! -f "$SETTINGS_FILE" ]; then
  # settings.json이 없으면 새로 생성
  cat > "$SETTINGS_FILE" << 'SETTINGS'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "f=(~/.claude/sounds/*.mp3); afplay \"${f[RANDOM % ${#f[@]}]}\" &",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
SETTINGS
  echo "✅ settings.json 생성 완료"
elif ! command -v jq &> /dev/null; then
  echo "⚠️  jq가 설치되어 있지 않아 settings.json을 자동으로 수정할 수 없습니다."
  echo ""
  echo "다음 중 하나를 선택하세요:"
  echo "  1) brew install jq 후 다시 실행"
  echo "  2) ~/.claude/settings.json에 아래 내용을 수동으로 추가:"
  echo ""
  echo '  "hooks": {'
  echo '    "Stop": [{'
  echo '      "hooks": [{'
  echo '        "type": "command",'
  echo "        \"command\": \"$HOOK_COMMAND\","
  echo '        "timeout": 10'
  echo '      }]'
  echo '    }]'
  echo '  }'
  exit 1
else
  # jq로 기존 settings.json에 hook 병합
  if echo "$(cat "$SETTINGS_FILE")" | jq -e '.hooks.Stop' &> /dev/null; then
    # 이미 Stop hook이 있는지 확인
    EXISTING=$(jq -r '.hooks.Stop[0].hooks[0].command // ""' "$SETTINGS_FILE")
    if [[ "$EXISTING" == *"afplay"*"sounds"* ]]; then
      echo "ℹ️  사운드 hook이 이미 설정되어 있습니다. 건너뜁니다."
    else
      # 기존 Stop hook 배열에 추가
      jq '.hooks.Stop += [{"hooks":[{"type":"command","command":"f=(~/.claude/sounds/*.mp3); afplay \"${f[RANDOM % ${#f[@]}]}\" &","timeout":10}]}]' \
        "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
      echo "✅ 기존 Stop hook에 사운드 hook 추가 완료"
    fi
  else
    # hooks.Stop이 없으면 추가
    jq '.hooks = (.hooks // {}) | .hooks.Stop = [{"hooks":[{"type":"command","command":"f=(~/.claude/sounds/*.mp3); afplay \"${f[RANDOM % ${#f[@]}]}\" &","timeout":10}]}]' \
      "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    echo "✅ settings.json에 Stop hook 추가 완료"
  fi
fi

echo ""
echo "🎉 설치 완료! Claude Code가 작업을 마칠 때마다 피크민 소리가 납니다."
echo "   제거하려면: ./uninstall.sh"
