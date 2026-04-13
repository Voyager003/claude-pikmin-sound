# Claude/Codex Pikmin Sound 🌱

Claude Code 또는 Codex CLI가 작업을 완료할 때마다 피크민 사운드가 랜덤으로 재생됩니다.

## 포함된 사운드

- 피크민 인사 (pikmin greet)
- 피크민 던지기 (pikmin throw)
- 흥 1, 2 (Hm)
- 한숨 (Sigh)
- 던지기 (Throw)

## 설치

```bash
git clone <REPO_URL> ~/.claude-pikmin-sound
cd ~/.claude-pikmin-sound
./install.sh
```

설치 스크립트는 다음 위치를 설정합니다.

- Claude Code: `~/.claude/settings.json`의 `Stop` hook
- Codex CLI: `~/.codex/hooks.json`의 `Stop` hook

기존 설정 파일이 있으면 `jq`로 기존 hook을 유지한 채 피크민 사운드 hook만 추가합니다.

## 제거

```bash
cd ~/.claude-pikmin-sound
./uninstall.sh
```

제거 스크립트는 `~/.claude/sounds/`, `~/.codex/sounds/`의 mp3 파일과 각 설정 파일에 추가된 피크민 사운드 hook만 제거합니다.

## 요구사항

- macOS (afplay 사용)
- [jq](https://jqlang.github.io/jq/) — 기존 `settings.json` 또는 `hooks.json` 수정 시 필요 (`brew install jq`)

## 동작 방식

Claude Code와 Codex CLI의 hook 기능을 사용합니다.

`~/.claude/settings.json`의 `Stop` hook에 사운드 재생 커맨드를 등록하여, Claude Code가 응답을 완료할 때마다 `~/.claude/sounds/` 디렉토리의 mp3 파일 중 하나를 랜덤 재생합니다.

`~/.codex/hooks.json`의 `Stop` hook에도 사운드 재생 커맨드를 등록하여, Codex CLI가 작업을 완료할 때마다 `~/.codex/sounds/` 디렉토리의 mp3 파일 중 하나를 랜덤 재생합니다.

## Codex 수동 적용

자동 설치를 사용하지 않으려면 mp3 파일을 `~/.codex/sounds/`에 복사한 뒤 `~/.codex/hooks.json`에 아래 hook을 추가하세요.

```json
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
```

## 커스터마이징

`~/.claude/sounds/` 또는 `~/.codex/sounds/`에 mp3 파일을 추가하면 랜덤 재생 대상에 포함됩니다.

## 라이선스

MIT
