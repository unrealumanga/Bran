# 🚀 Bran (God Mode)

**Transform any AI coding agent into an elite, polyglot System Architect.**

**Tags:** `claude-code` `opencode` `system-prompt` `polyglot` `uv` `nix` `vite` `ollama` `local-ai`

Are you trying to use advanced CLI agents like **Claude Code**, **OpenCode**, or **Cursor**, only to watch them write conversational fluff, use outdated tools like `pip` or `webpack`, and completely hallucinate when jumping between Python, Rust, and Go?

**Bran (God Mode)** solves this instantly.

By dropping a single, highly-optimized XML file into your workspace, you inject a strict, zero-tolerance "Principal Engineer" persona directly into your AI. The result? A hyper-focused agent that natively understands modern tech stacks, enforces Test-Driven Development, and mandates the fastest build tools on earth.

## 🧪 Case Study: Bran + Claude Code + Local Aria Models
Want to run Claude Code locally for **$0/month** without sacrificing reasoning quality? 

We paired the **Bran (God Mode)** XML prompt with [Aria RAG Harness](https://github.com/unrealumanga/Aria) (specifically the `aria-qwen9b` model running locally on Ollama). 

**The Result:**
Because Bran forces strict, XML-based reasoning frameworks, the local Qwen 9B model performed like a massive 70B parameter model. It bypassed conversational fluff, natively utilized `<think>` blocks in the terminal, and successfully simulated Anthropic's tool-calling logic directly from `localhost:11434`. 

```bash
# Run Claude Code 100% locally with Bran + Aria!
export ANTHROPIC_API_KEY="sk-local"
export ANTHROPIC_BASE_URL="http://127.0.0.1:11434"

claude -p "Refactor this python script to use Rust via PyO3" --model aria-qwen9b:latest
```

## ✨ Features

- **🔌 Dynamic Context Routing:** Bakes intelligent routing into the AI. It detects if you're building a Blender Addon, a ComfyUI workflow, or a hybrid Rust/Python app, and adapts its architecture rules instantly.
- **🧠 The Bran Persona:** Strips away the "Here is the code..." fluff. Your agent adopts the "Bran" persona—sharp, direct, and focused entirely on executing targeted code edits and bash commands.
- **🛠️ The Elite Tech Stack:** Bypasses legacy systems. Bran forces the AI to use `uv` (Python), `Vite` (Web), `Maturin` (Rust/Python FFI), and `Nix` (Environments) for lightning-fast, reproducible builds.
- **🔒 Mandatory Scratchpads:** Forces Chain-of-Thought (CoT) reasoning. The AI *must* open a `<scratchpad>` to analyze the blast radius before it is allowed to modify a single file.

## 🛠️ Quick Start

You don't need to install any complex software. Just grab the XML file and drop it into your workspace.

**Global Installation (Recommended for Claude Code):**
Apply Bran to every project you open.

```bash
# Windows (PowerShell)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/unrealumanga/Bran/main/CLAUDE.md" -OutFile "$env:USERPROFILE\.claude\CLAUDE.md"

# Linux / Mac
curl -o ~/.claude/CLAUDE.md https://raw.githubusercontent.com/unrealumanga/Bran/main/CLAUDE.md
```

**Local Project Installation:**
Apply Bran to a single, specific project folder.

```bash
curl -o CLAUDE.md https://raw.githubusercontent.com/unrealumanga/Bran/main/CLAUDE.md
```

## 🧠 Optimization Tricks: Why XML?

You might wonder why Bran is written in XML instead of standard Markdown. 

Anthropic's Claude models are heavily fine-tuned to parse XML tags. By wrapping our system directives in tags like `<context_routing>` and `<elite_build_tools>`, we create strict boundaries in the model's attention mechanism. This prevents "context bleed" (where the AI accidentally uses Python rules in a Rust file) and drastically reduces token hallucination during long coding sessions.
