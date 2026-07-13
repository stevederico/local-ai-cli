#!/usr/bin/env bash
# install-stt.sh — set up local speech-to-text (whisper.cpp) on a fresh macOS
# Apple-Silicon machine. Idempotent: re-run anytime; existing pieces are skipped.
#
# Installs (into ~/.local/opt, CLIs symlinked into ~/.local/bin):
#   - whisper.cpp (built from source, Metal; whisper-cli/-stream/-server)
#   - ggml-large-v3-turbo transcription model
set -euo pipefail

OPT="$HOME/.local/opt"
BIN="$HOME/.local/bin"
WHISPER_DIR="$OPT/whisper.cpp"
WHISPER_MODEL="large-v3-turbo"

log() { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }

[ "$(uname -s)" = Darwin ] && [ "$(uname -m)" = arm64 ] || {
  echo "error: this installer targets macOS Apple Silicon (got $(uname -s)/$(uname -m))" >&2; exit 1; }

MISSING=""
for t in git cmake clang ffmpeg curl; do command -v "$t" >/dev/null || MISSING="$MISSING $t"; done
if [ -n "$MISSING" ]; then
  echo "error: missing tools:$MISSING" >&2
  echo "install with: brew install cmake ffmpeg   (git/clang come with Xcode CLT: xcode-select --install)" >&2
  exit 1
fi
mkdir -p "$OPT" "$BIN"

# --- whisper.cpp --------------------------------------------------------------
if [ ! -x "$WHISPER_DIR/build/bin/whisper-cli" ]; then
  log "Building whisper.cpp"
  [ -d "$WHISPER_DIR/.git" ] || git clone --depth 1 https://github.com/ggml-org/whisper.cpp.git "$WHISPER_DIR"
  SDL2=OFF; [ -e /opt/homebrew/lib/libSDL2.dylib ] && SDL2=ON
  cmake -S "$WHISPER_DIR" -B "$WHISPER_DIR/build" -DWHISPER_SDL2=$SDL2 -DCMAKE_BUILD_TYPE=Release
  cmake --build "$WHISPER_DIR/build" -j --config Release
else
  log "whisper.cpp already built — skip"
fi
for b in whisper-cli whisper-stream whisper-server; do
  [ -e "$WHISPER_DIR/build/bin/$b" ] && ln -sf "$WHISPER_DIR/build/bin/$b" "$BIN/$b"
done

# --- model --------------------------------------------------------------------
if [ ! -f "$WHISPER_DIR/models/ggml-${WHISPER_MODEL}.bin" ]; then
  log "Downloading whisper model: $WHISPER_MODEL"
  ( cd "$WHISPER_DIR" && bash models/download-ggml-model.sh "$WHISPER_MODEL" )
else
  log "whisper model present — skip"
fi

log "Done"
echo "verify: transcribe $WHISPER_DIR/samples/jfk.wav"
