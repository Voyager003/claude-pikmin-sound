#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SOUNDS_DIR="$CLAUDE_DIR/sounds"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
CODEX_DIR="$HOME/.codex"
CODEX_SOUNDS_DIR="$CODEX_DIR/sounds"
CODEX_HOOKS_FILE="$CODEX_DIR/hooks.json"

echo "🌱 Claude/Codex Pikmin Sound 설치 중..."

# 1. sounds 디렉토리 생성 및 파일 복사
mkdir -p "$SOUNDS_DIR"
cp "$SCRIPT_DIR"/sounds/*.mp3 "$SOUNDS_DIR/"
echo "✅ 사운드 파일 복사 완료 → $SOUNDS_DIR"

mkdir -p "$CODEX_SOUNDS_DIR"
cp "$SCRIPT_DIR"/sounds/*.mp3 "$CODEX_SOUNDS_DIR/"
echo "✅ Codex 사운드 파일 복사 완료 → $CODEX_SOUNDS_DIR"

# 2. Claude settings.json에 Stop hook 추가
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
    if jq -e --arg marker ".claude/sounds" '.hooks.Stop[]?.hooks[]? | select((.command // "") | contains($marker))' "$SETTINGS_FILE" &> /dev/null; then
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

# 3. Codex hooks.json에 Stop hook 추가
CODEX_HOOK_COMMAND="/bin/bash --noprofile --norc -c 'shopt -s nullglob; f=(~/.codex/sounds/*.mp3); ((\${#f[@]})) && afplay \"\${f[RANDOM % \${#f[@]}]}\" >/dev/null 2>&1 &'"

if [ ! -f "$CODEX_HOOKS_FILE" ]; then
  # hooks.json이 없으면 새로 생성
  cat > "$CODEX_HOOKS_FILE" << 'HOOKS'
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "/bin/bash --noprofile --norc -c 'shopt -s nullglob; f=(~/.codex/sounds/*.mp3); ((${#f[@]})) && afplay \"${f[RANDOM % ${#f[@]}]}\" >/dev/null 2>&1 &'",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
HOOKS
  echo "✅ Codex hooks.json 생성 완료"
elif ! command -v jq &> /dev/null; then
  echo "⚠️  jq가 설치되어 있지 않아 hooks.json을 자동으로 수정할 수 없습니다."
  echo ""
  echo "다음 중 하나를 선택하세요:"
  echo "  1) brew install jq 후 다시 실행"
  echo "  2) ~/.codex/hooks.json에 아래 내용을 수동으로 추가:"
  echo ""
  cat << 'MANUAL'
  "hooks": {
    "Stop": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "/bin/bash --noprofile --norc -c 'shopt -s nullglob; f=(~/.codex/sounds/*.mp3); ((${#f[@]})) && afplay \"${f[RANDOM % ${#f[@]}]}\" >/dev/null 2>&1 &'",
        "timeout": 10
      }]
    }]
  }
MANUAL
  exit 1
else
  # jq로 기존 hooks.json에 hook 병합
  if jq -e --arg marker ".codex/sounds" '.hooks.Stop[]?.hooks[]? | select((.command // "") | contains($marker))' "$CODEX_HOOKS_FILE" &> /dev/null; then
    echo "ℹ️  Codex 사운드 hook이 이미 설정되어 있습니다. 건너뜁니다."
  else
    jq --arg command "$CODEX_HOOK_COMMAND" \
      '.hooks = (.hooks // {}) | .hooks.Stop = ((.hooks.Stop // []) + [{"matcher":"*","hooks":[{"type":"command","command":$command,"timeout":10}]}])' \
      "$CODEX_HOOKS_FILE" > "$CODEX_HOOKS_FILE.tmp" && mv "$CODEX_HOOKS_FILE.tmp" "$CODEX_HOOKS_FILE"
    echo "✅ Codex hooks.json에 Stop hook 추가 완료"
  fi
fi

echo ""
echo "🎉 설치 완료! Claude Code 또는 Codex CLI가 작업을 마칠 때마다 피크민 소리가 납니다."
echo "   제거하려면: ./uninstall.sh"
