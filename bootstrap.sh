#!/bin/bash

# Bran Auto-Stack Bootstrap
# This script sets up the entire OpenClaw Local Stack: Ollama + Aria + Bran.

set -e

# --- Configuration ---
DEFAULT_MODEL_GGUF_URL="https://huggingface.co/QuantFactory/Qwen2-7B-Instruct-GGUF/resolve/main/qwen2-7b-instruct-q4_k_m.gguf"
DEFAULT_MODEL_NAME="qwen2:7b"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ARIA_REPO_PATH="${SCRIPT_DIR}/../Aria" # Assuming Aria repo is adjacent to Bran

# --- Helper Functions ---
print_header() {
    echo "================================================="
    echo "  🚀 Bran Auto-Stack Bootstrap"
    echo "================================================="
}

print_step() {
    echo "➡️  $1"
}

print_success() {
    echo "✅ $1"
}

print_error() {
    echo "❌ ERROR: $1" >&2
    exit 1
}

# --- Main Logic ---
print_header

# Step 1: Hardware Detection
print_step "Detecting hardware..."
if ! command -v nvidia-smi &> /dev/null; then
    print_error "NVIDIA GPU not detected. This script currently requires an NVIDIA GPU and nvidia-smi."
fi

VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1)
if   [ "$VRAM" -ge 16000 ]; then QUANT="Q8_0";   CTX=65536; VRAM_EST="~15GB"
elif [ "$VRAM" -ge 8000  ]; then QUANT="Q8_0";   CTX=32768; VRAM_EST="~7.2GB"
elif [ "$VRAM" -ge 6000  ]; then QUANT="Q4_K_M"; CTX=16384; VRAM_EST="~5GB"
else
    print_error "Minimum 6GB of VRAM required. Detected ${VRAM}MB."
fi
echo "   Detected ${VRAM}MB VRAM. Selected Quantization: $QUANT, Context: $CTX"

# Step 2: Ollama Setup
print_step "Checking for Ollama..."
if ! command -v ollama &> /dev/null; then
    print_step "Ollama not found. Installing..."
    curl -fsSL https://ollama.com/install.sh | sh
    print_success "Ollama installed."
else
    print_success "Ollama is already installed."
fi
# Ensure Ollama server is running
pgrep -f "ollama serve" >/dev/null || ollama serve &
sleep 5 # Give it a moment to start

# Step 3: Aria Harness
print_step "Harnessing model with Aria..."
if [ ! -f "${ARIA_REPO_PATH}/generate_harness.py" ]; then
    print_error "Aria repository not found at ${ARIA_REPO_PATH}. Please clone it next to the Bran repo."
fi

# Define a name for the harnessed model based on the persona
HARNESSED_MODEL_NAME="aria-local-${PERSONA}"
GGUF_FILENAME=$(basename "$DEFAULT_MODEL_GGUF_URL")
GGUF_LOCAL_PATH="${ARIA_REPO_PATH}/${GGUF_FILENAME}"

# Download the base model GGUF if it doesn't exist
if [ ! -f "$GGUF_LOCAL_PATH" ]; then
    print_step "Downloading base model GGUF to Aria directory..."
    wget -q --show-progress -O "$GGUF_LOCAL_PATH" "$DEFAULT_MODEL_GGUF_URL"
fi

print_step "Running Aria harness generator..."
(
    cd "${ARIA_REPO_PATH}" || exit
    python3 generate_harness.py \
        --name "${HARNESSED_MODEL_NAME}" \
        --base "./${GGUF_FILENAME}" \
        --ctx "${CTX}" \
        --persona "${PERSONA}" \
        --non-interactive
)

MODELFILE_PATH="${ARIA_REPO_PATH}/modelfiles/Modelfile.${HARNESSED_MODEL_NAME}"
if [ ! -f "$MODELFILE_PATH" ]; then
    print_error "Aria harness generator failed to create the Modelfile."
fi

print_step "Creating harnessed model '${HARNESSED_MODEL_NAME}' with Ollama..."
ollama create "${HARNESSED_MODEL_NAME}" -f "${MODELFILE_PATH}"
print_success "Aria model '${HARNESSED_MODEL_NAME}' created."

# Step 4: Bran Injection
# ... (rest of the script is the same)

print_step "Injecting Bran persona..."

if [ -n "$1" ]; then
    PERSONA=$1
else
    echo "Please select a Bran persona to install:"
    personas=(base $(ls -1 personas | sed -e 's/bran-//' -e 's/.md//' | tr '\n' ' '))
    select p in "${personas[@]}"; do
        if [[ -n "$p" ]]; then
            PERSONA=$p
            break
        else
            echo "Invalid selection."
        fi
    done
fi

if [ "$PERSONA" == "base" ]; then
    SOURCE_PROMPT_PATH="./CLAUDE.md"
else
    SOURCE_PROMPT_PATH="./personas/bran-${PERSONA}.md"
fi

if [ ! -f "$SOURCE_PROMPT_PATH" ]; then
    print_error "Persona file not found at ${SOURCE_PROMPT_PATH}"
fi

mkdir -p ~/.claude
cp "$SOURCE_PROMPT_PATH" ~/.claude/CLAUDE.md
print_success "Bran '${PERSONA}' persona injected globally to ~/.claude/CLAUDE.md"

# Step 5: Verification Test
print_step "Running verification test..."
# We use the tester script we just built
if [ ! -f "./tester/benchmark.py" ]; then
    print_error "Bran tester not found. Cannot verify installation."
fi

# Check for requirements
pip install -r ./tester/requirements.txt -q
VERIFICATION_PROMPT="Write a Python function that computes fibonacci(n) iteratively."
# In the future, this would target `aria-local`
VERIFICATION_OUTPUT=$(python ./tester/benchmark.py --model ${DEFAULT_MODEL_NAME} --prompt "${VERIFICATION_PROMPT}")

if ! echo "${VERIFICATION_OUTPUT}" | grep -q "Fluff Reduction"; then
    print_error "Verification test failed. Could not determine fluff reduction."
fi
FLUFF_REDUCTION_LINE=$(echo "${VERIFICATION_OUTPUT}" | grep "Fluff Reduction")
print_success "Verification complete. ${FLUFF_REDUCTION_LINE}"

# Step 6: Summary Card
cat << EOF

╔═════════════════════════════════════════════════════════════════╗
║                OpenClaw Local Stack — READY                     ║
╠═════════════════════════════════════════════════════════════════╣
║   Model       ${HARNESSED_MODEL_NAME} (${QUANT}, ${DEFAULT_MODEL_NAME} base)      ║
║   Context     ${CTX} tokens                                     ║
║   VRAM est.   ${VRAM_EST} active / ${VRAM}MB available                 ║
║   Persona     Bran [${PERSONA}] → ~/.claude/CLAUDE.md                 ║
╠═════════════════════════════════════════════════════════════════╣
║   Launch:     claude --model ${HARNESSED_MODEL_NAME}                      ║
║   Or:         python ../Nedster/main.py chat                       ║
╚═════════════════════════════════════════════════════════════════╝
EOF
