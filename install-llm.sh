#!/usr/bin/env bash
# install-llm.sh — set up local LLM inference on a fresh macOS Apple-Silicon
# machine. Idempotent: re-run anytime; an existing build is skipped.
#
# Builds llama.cpp from source (Metal) into ~/.local/opt/llama.cpp and symlinks
# its CLIs into ~/.local/bin (llama-cli, llama-server, llama-bench, llama-quantize).
#
# mlx-lm and LM Studio are managed separately — see brain refs/local-llm-stack.md.
set -euo pipefail

OPT="$HOME/.local/opt"
BIN="$HOME/.local/bin"
DIR="$OPT/llama.cpp"

log() { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }

[ "$(uname -s)" = Darwin ] && [ "$(uname -m)" = arm64 ] || {
  echo "error: this installer targets macOS Apple Silicon (got $(uname -s)/$(uname -m))" >&2; exit 1; }

MISSING=""
for t in git cmake clang curl; do command -v "$t" >/dev/null || MISSING="$MISSING $t"; done
if [ -n "$MISSING" ]; then
  echo "error: missing tools:$MISSING" >&2
  echo "install with: brew install cmake   (git/clang come with Xcode CLT: xcode-select --install)" >&2
  exit 1
fi
mkdir -p "$OPT" "$BIN"

if [ ! -x "$DIR/build/bin/llama-cli" ]; then
  log "Building llama.cpp"
  [ -d "$DIR/.git" ] || git clone --depth 1 https://github.com/ggml-org/llama.cpp.git "$DIR"
  cmake -S "$DIR" -B "$DIR/build" -DCMAKE_BUILD_TYPE=Release
  cmake --build "$DIR/build" -j --config Release
else
  log "llama.cpp already built — skip"
fi

# NOTE: recent llama.cpp split the CLI — llama-cli is interactive-only, one-shot
# scripted generation is now llama-completion (needs --jinja for gemma templates).
for b in llama-cli llama-completion llama-server llama-bench llama-quantize; do
  [ -e "$DIR/build/bin/$b" ] && ln -sf "$DIR/build/bin/$b" "$BIN/$b"
done

log "Done"
echo "run a model (downloads from HF on first use):"
echo "  llama-cli        -hf ggml-org/gemma-4-12B-it-GGUF --jinja          # interactive chat"
echo "  llama-completion -hf ggml-org/gemma-4-12B-it-GGUF --jinja -p 'hi'  # one-shot / scripting"
echo "  llama-server     -hf ggml-org/gemma-4-12B-it-GGUF --jinja --port 8080"
