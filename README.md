# local-ai-cli

**Superseded.** Use these instead:

| Job | Repo | CLI |
|---|---|---|
| Local LLM (`ask`, warm `llm-server`) | [dottie-local](https://github.com/stevederico/dottie-local) | `ask` · `llm-server` · `dottie-local` |
| STT / TTS | [dottie-talk](https://github.com/stevederico/dottie-talk) | `dottie-talk transcribe` · `dottie-talk speak` |

```sh
# LLM — npm link puts ask + llm-server on PATH
git clone https://github.com/stevederico/dottie-local.git
cd dottie-local && npm install && npm link
ask "hello"
llm-server status

# Voice
git clone https://github.com/stevederico/dottie-talk.git
cd dottie-talk && npm install
npx dottie-talk transcribe clip.wav
npx dottie-talk speak "hi" -o hi.wav
```

`dottie-local` needs [`llama-server`](https://github.com/ggml-org/llama.cpp) on `PATH` (build via your usual llama.cpp install, e.g. `~/.dotfiles/llm/install-llm.sh` on this machine).

## What lived here

Bash wrappers + Metal build scripts for llama.cpp / whisper.cpp. Kept only as history — do not install from this repo if dottie-local / dottie-talk are available (PATH will shadow).

| Old command | Now |
|---|---|
| `ask` / `llm-server` | **dottie-local** (same bin names) |
| `transcribe` (whisper.cpp) | **dottie-talk** (parakeet / voxtype — not whisper) |

## License

MIT
