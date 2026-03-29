# Claude Pikmin Sound 🌱

Claude Code가 작업을 완료할 때마다 피크민 사운드가 랜덤으로 재생됩니다.

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

## 제거

```bash
cd ~/.claude-pikmin-sound
./uninstall.sh
```

## 요구사항

- macOS (afplay 사용)
- [jq](https://jqlang.github.io/jq/) — 기존 `settings.json` 수정 시 필요 (`brew install jq`)

## 동작 방식

Claude Code의 [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) 기능을 사용합니다.

`~/.claude/settings.json`의 `Stop` hook에 사운드 재생 커맨드를 등록하여, Claude Code가 응답을 완료할 때마다 `~/.claude/sounds/` 디렉토리의 mp3 파일 중 하나를 랜덤 재생합니다.

## 커스터마이징

`~/.claude/sounds/`에 mp3 파일을 추가하면 랜덤 재생 대상에 포함됩니다.

## 라이선스

MIT
