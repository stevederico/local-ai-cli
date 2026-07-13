# ask-transcribe-cli

Two tiny CLIs for **local** LLM and speech-to-text on macOS Apple Silicon —
`ask` a warm local model, `transcribe` audio to text. Pure C++/Metal engines
([llama.cpp](https://github.com/ggml-org/llama.cpp) +
[whisper.cpp](https://github.com/ggml-org/whisper.cpp)), **no Python**, no cloud.

## Quick start

macOS Apple Silicon. One line — builds both engines, installs the CLIs:

```sh
git clone https://github.com/stevederico/ask-transcribe-cli.git && cd ask-transcribe-cli && bash setup.sh
```

Then:

```sh
ask "explain the CAP theorem in one line"
echo "$(cat article.txt)" | ask "summarize this"
transcribe interview.mp3
```

## Why

- **Warm server.** The LLM loads once and stays resident (`llm-server`), so
  `ask` answers in ~3s instead of reloading a 12B model every call.
- **One command.** `setup.sh` builds both engines from source (Metal GPU),
  symlinks the CLIs, and downloads the whisper model.
- **No runtime deps.** Both engines are C++ on ggml. No Python, no venv, no uvx.

## Prerequisites

`setup.sh` auto-installs its build deps (`cmake`, `ffmpeg`, `node`) via
[Homebrew](https://brew.sh). You only need the two things brew can't provide:

```sh
xcode-select --install   # git + clang (skip if already installed)
# + Homebrew installed (https://brew.sh)
```

Also ensure `~/.local/bin` is on your `PATH`. The whisper model downloads during
`setup.sh`; the LLM model downloads from Hugging Face on your first `ask`.

## Usage

### `ask` — query the local LLM

```sh
ask "your question"
echo "long text" | ask "summarize this"   # stdin is appended to the prompt
```

| Env | Default | Meaning |
|---|---|---|
| `LLM_PORT` | `8080` | server port |
| `LLM_REASON` | `0` | set `1` to enable gemma's thinking (slower) |

### `llm-server` — manage the warm daemon

```sh
llm-server start|stop|restart|status|log   # ask auto-starts it; manage by hand if you like
```

| Env | Default | Meaning |
|---|---|---|
| `LLM_PORT` | `8080` | server port |
| `LLM_MODEL` | `ggml-org/gemma-4-12B-it-GGUF` | HF GGUF repo or local path; append `:Q4_K_M` etc. to pick a quant |
| `LLM_NGL` | `999` | GPU layers (999 = all on Metal) |

Prefers a locally cached **Q8_0** GGUF (loads with `-m`, no network). Lighter:
`LLM_MODEL=ggml-org/gemma-4-E4B-it-GGUF`.

### Recommended models

Point `LLM_MODEL` at any GGUF repo (or local path); `llm-server` downloads it on
first start. All sizes are for the default quant.

| Use | `LLM_MODEL` | Size | Notes |
|---|---|---|---|
| **Default** | `ggml-org/gemma-4-12B-it-GGUF` (Q8_0) | ~13 GB | best balance, ~23 tok/s. **Avoid this repo's Q4_K_M** — broken template floods `<unused50>`; stick to Q8_0 |
| Light / low-RAM | `ggml-org/gemma-4-E4B-it-GGUF` | ~4 GB | faster, weaker |
| Light (official Nemotron) | `nvidia/NVIDIA-Nemotron-3-Nano-4B-GGUF` | ~2.5 GB | NVIDIA-published GGUF (Q4_K_M only) |
| Tiny / edge | `ggml-org/gemma-4-E2B-it-GGUF` | ~2 GB | smallest |
| Smarter reasoning | `unsloth/NVIDIA-Nemotron-3-Nano-30B-A3B-GGUF` | ~18–30 GB | 30B MoE, strong reasoning. Community quant (no official GGUF at this size); pick one that fits RAM |

Skip 70B+ dense and the 120B/550B Nemotrons on a laptop — too slow to be pleasant.

### `transcribe` — audio to text

```sh
transcribe audio.wav
transcribe clip.mp3 interview.flac        # multiple files
transcribe audio.wav -- -osrt -of out     # pass extra whisper-cli flags after --
```

| Env | Default | Meaning |
|---|---|---|
| `STT_MODEL` | `large-v3-turbo` | whisper model path |
| `STT_LANG` | `en` | source language |
| `STT_TRANSLATE` | `0` | set `1` to translate to English |
| `STT_VERBOSE` | `0` | set `1` to show whisper-cli's stderr |

## What's in the box

| File | Does |
|---|---|
| `setup.sh` | installs deps (brew), builds both engines, symlinks all CLIs |
| `install-llm.sh` | builds llama.cpp (Metal) → `~/.local/opt/llama.cpp` |
| `install-stt.sh` | builds whisper.cpp + downloads `large-v3-turbo` |
| `ask` | streams an answer from the warm LLM |
| `llm-server` | start/stop/status the persistent model server |
| `transcribe` | whisper.cpp wrapper with sane defaults |

## License

MIT
