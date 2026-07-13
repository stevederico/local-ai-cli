#!/usr/bin/env bash
# setup.sh — install both engines (llama.cpp + whisper.cpp) and put the CLIs on
# PATH. Idempotent: re-run anytime; existing builds are skipped.
#
# Builds from source (Metal) into ~/.local/opt and symlinks CLIs into
# ~/.local/bin. Then symlinks this repo's wrapper scripts (ask, llm-server,
# transcribe) there too, so they work from anywhere.
set -euo pipefail

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"

# Ensure build/runtime deps. cmake builds the engines, ffmpeg decodes audio for
# transcribe, node runs ask's JSON/SSE glue. Auto-install via Homebrew if present.
DEPS=(cmake ffmpeg node)
MISSING=()
for d in "${DEPS[@]}"; do command -v "$d" >/dev/null || MISSING+=("$d"); done
if [ ${#MISSING[@]} -gt 0 ]; then
  if command -v brew >/dev/null; then
    printf '\n\033[1m== Installing deps: %s ==\033[0m\n' "${MISSING[*]}"
    brew install "${MISSING[@]}"
  else
    echo "error: missing deps: ${MISSING[*]}" >&2
    echo "install Homebrew (https://brew.sh) then: brew install ${MISSING[*]}" >&2
    echo "(git + clang come from Xcode CLT: xcode-select --install)" >&2
    exit 1
  fi
fi

bash "$SELF_DIR/install-llm.sh"
bash "$SELF_DIR/install-stt.sh"

mkdir -p "$BIN"
for s in ask llm-server transcribe; do
  ln -sf "$SELF_DIR/$s" "$BIN/$s"
done

printf '\n\033[1m== Done ==\033[0m\n'
echo "make sure ~/.local/bin is on your PATH, then:"
echo "  ask \"what is the capital of France?\""
echo "  transcribe recording.mp3"
