# local-ai-cli

Install scripts + thin bash wrappers for local LLM and STT on macOS Apple Silicon
([llama.cpp](https://github.com/ggml-org/llama.cpp) +
[whisper.cpp](https://github.com/ggml-org/whisper.cpp)).

**Prefer the dottie CLIs** — same jobs, HTTP/MCP too:

| Job | Use |
|---|---|
| Ask a local model | [`dottie-local ask`](https://github.com/stevederico/dottie-local) |
| Transcribe / speak | [`dottie-talk`](https://github.com/stevederico/dottie-talk) |

```sh
dottie-local ask "explain the CAP theorem in one line"
dottie-talk transcribe interview.wav
dottie-talk speak "hello" -o hello.wav
```

This repo still builds the engines and ships `ask` / `transcribe` / `llm-server` if you want zero-Node shell tools. `dottie-local` reuses a healthy `llama-server` on `:8080` (including one started by `llm-server` here).

## Quick start (dottie)

```sh
# tokens (needs llama-server on PATH — install-llm.sh below, or your own build)
git clone https://github.com/stevederico/dottie-local.git && cd dottie-local && npm install
dottie-local ask "hello"

# voice
git clone https://github.com/stevederico/dottie-talk.git && cd dottie-talk && npm install
dottie-talk transcribe clip.wav
dottie-talk speak "hi" -o hi.wav
```

## Quick start (this repo — engines + bash CLIs)

macOS Apple Silicon. Builds both engines, installs the bash CLIs:

```sh
git clone https://github.com/stevederico/local-ai-cli.git && cd local-ai-cli && bash setup.sh
```

```sh
ask "explain the CAP theorem in one line"
echo "$(cat article.txt)" | ask "summarize this"
transcribe interview.mp3
```

## Why two layers

- **dottie-local / dottie-talk** — Node façade: CLI + HTTP + MCP. Prefer these day to day.
- **local-ai-cli** — build Metal engines from source, optional bare bash (`ask`, `transcribe`, `llm-server`). No Python runtime for the engines.

## Prerequisites

`setup.sh` auto-installs build deps (`cmake`, `ffmpeg`, `node`) via
[Homebrew](https://brew.sh). You only need:

```sh
xcode-select --install   # git + clang (skip if already installed)
# + Homebrew installed (https://brew.sh)
```

Ensure `~/.local/bin` is on your `PATH`. Whisper model downloads during `setup.sh`;
the LLM GGUF downloads from Hugging Face on first ask (bash or dottie-local).

## Bash usage (legacy / zero-Node)

### `ask`

```sh
ask "your question"
echo "long text" | ask "summarize this"
```

| Env | Default | Meaning |
|---|---|---|
| `LLM_PORT` | `8080` | server port |
| `LLM_REASON` | `0` | set `1` to enable gemma thinking (slower) |

### `llm-server`

```sh
llm-server start|stop|restart|status|log
```

| Env | Default | Meaning |
|---|---|---|
| `LLM_PORT` | `8080` | server port |
| `LLM_MODEL` | `ggml-org/gemma-4-12B-it-GGUF` | HF GGUF repo or local path; append `:Q4_K_M` etc. for quant |
| `LLM_NGL` | `999` | GPU layers (999 = all on Metal) |

Prefers cached **Q8_0**. Lighter: `LLM_MODEL=ggml-org/gemma-4-E4B-it-GGUF`.

### Recommended models

| Use | `LLM_MODEL` | Size | Notes |
|---|---|---|---|
| **Default** | `ggml-org/gemma-4-12B-it-GGUF` (Q8_0) | ~13 GB | best balance. **Avoid this repo's Q4_K_M** — broken template floods `<unused50>` |
| Light / low-RAM | `ggml-org/gemma-4-E4B-it-GGUF` | ~4 GB | faster, weaker |
| Light (official Nemotron) | `nvidia/NVIDIA-Nemotron-3-Nano-4B-GGUF` | ~2.5 GB | Q4_K_M only |
| Tiny / edge | `ggml-org/gemma-4-E2B-it-GGUF` | ~2 GB | smallest |
| Smarter reasoning | `unsloth/NVIDIA-Nemotron-3-Nano-30B-A3B-GGUF` | ~18–30 GB | 30B MoE; pick quant that fits RAM |

Skip 70B+ dense on a laptop.

### `transcribe`

Batch whisper.cpp (files). For realtime / TTS use **dottie-talk**.

```sh
transcribe audio.wav
transcribe clip.mp3 interview.flac
transcribe audio.wav -- -osrt -of out
```

| Env | Default | Meaning |
|---|---|---|
| `STT_MODEL` | `large-v3-turbo` | whisper model path |
| `STT_LANG` | `en` | source language |
| `STT_TRANSLATE` | `0` | set `1` to translate to English |
| `STT_VERBOSE` | `0` | set `1` to show whisper-cli stderr |

## What's in the box

| File | Does |
|---|---|
| `setup.sh` | brew deps, builds both engines, symlinks bash CLIs |
| `install-llm.sh` | builds llama.cpp (Metal) → `~/.local/opt/llama.cpp` |
| `install-stt.sh` | builds whisper.cpp + downloads `large-v3-turbo` |
| `ask` | streams an answer from the warm LLM |
| `llm-server` | start/stop/status the persistent model server |
| `transcribe` | whisper.cpp wrapper with sane defaults |

## Related

- [dottie-local](https://github.com/stevederico/dottie-local) — `ask` / agent / HTTP / MCP over llama.cpp
- [dottie-talk](https://github.com/stevederico/dottie-talk) — `speak` / `transcribe` / HTTP / MCP (parakeet + koko)
- [dottie-desktop](https://github.com/stevederico/dottie-desktop) — desktop app

## License

MIT
