#!/bin/bash

# ==========================================
# Ostris AI Toolkit - 50-Series Installer
# Fix: Dynamic Environment Path Detection
# ==========================================

# --- STEP 1: INITIAL SETUP ---
echo ">>> Detecting Conda..."

# Get Conda Base
CONDA_BASE=$(conda info --base 2>/dev/null)

# Fallback detection
if [ -z "$CONDA_BASE" ]; then
    if [ -d "/opt/conda" ]; then CONDA_BASE="/opt/conda"; fi
    if [ -d "/root/miniconda3" ]; then CONDA_BASE="/root/miniconda3"; fi
fi

if [ -z "$CONDA_BASE" ]; then
    echo "CRITICAL ERROR: Could not find Conda base."
    exit 1
fi

echo ">>> Found Conda at: $CONDA_BASE"
source "$CONDA_BASE/etc/profile.d/conda.sh"

# Deactivate main to be safe
conda deactivate 2>/dev/null
conda deactivate 2>/dev/null

# --- STEP 2: CREATE ENVIRONMENT ---
echo ">>> Creating 'toolkit' environment (Python 3.10)..."
conda env remove -n toolkit -y 2>/dev/null
conda create -n toolkit python=3.10 -y

# --- STEP 3: LOCATE ENVIRONMENT (THE FIX) ---
echo ">>> Locating new environment..."

# We ask Conda where it put 'toolkit' instead of guessing
# This handles cloud instances with custom env paths
TK_ENV_PATH=$(conda env list | grep -w "toolkit" | awk '{print $NF}' | head -n 1)

if [ -z "$TK_ENV_PATH" ]; then
    echo "CRITICAL ERROR: Conda reported success, but could not find 'toolkit' in env list."
    echo "Debug Info:"
    conda env list
    exit 1
fi

echo ">>> Environment located at: $TK_ENV_PATH"

# Define direct paths to binaries
TK_PYTHON="$TK_ENV_PATH/bin/python"
TK_PIP="$TK_ENV_PATH/bin/pip"

# Verify pip exists
if [ ! -f "$TK_PIP" ]; then
    echo "CRITICAL ERROR: pip not found at $TK_PIP"
    exit 1
fi

echo ">>> Targeted Installation Path: $TK_PIP"

# --- STEP 4: CLONE REPO ---
cd /workspace
rm -rf ai-toolkit
git clone --depth 1 https://github.com/ostris/ai-toolkit
cd ai-toolkit

# --- STEP 5: WRITE REQUIREMENTS ---
echo ">>> Writing 50-Series Requirements..."
cat <<EOF > requirements.txt
--extra-index-url https://download.pytorch.org/whl/cu129
torch==2.8.0
torchvision
torchaudio
flash_attn @ https://huggingface.co/MonsterMMORPG/Wan_GGUF/resolve/main/flash_attn-2.8.2-cp310-cp310-linux_x86_64.whl ; sys_platform == 'linux'
xformers @ https://huggingface.co/MonsterMMORPG/Wan_GGUF/resolve/main/xformers-0.0.33+c159edc0.d20250906-cp39-abi3-linux_x86_64.whl ; sys_platform == 'linux'
sageattention @ https://huggingface.co/MonsterMMORPG/Wan_GGUF/resolve/main/sageattention-2.2.0-cp39-abi3-linux_x86_64.whl ; sys_platform == 'linux'
hf_xet
EOF

# --- STEP 6: INSTALL DEPENDENCIES ---
echo ">>> Installing Python Packages..."

# Upgrade pip
"$TK_PYTHON" -m pip install --upgrade pip

# 1. Install Torch Stack
echo ">>> Installing Torch 2.8..."
"$TK_PIP" install "torch==2.8.0" torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129

# 2. Install Custom Wheels
echo ">>> Installing Custom Wheels..."
"$TK_PIP" install -r requirements.txt

# 3. Patch Transformers
echo ">>> Patching Transformers..."
"$TK_PIP" install -U transformers diffusers accelerate peft huggingface_hub[cli] protobuf --extra-index-url https://download.pytorch.org/whl/cu129

# --- STEP 7: MEMORY FIXES ---
echo ">>> Applying Memory Fixes..."
conda activate toolkit
conda env config vars set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:512
conda deactivate

# --- STEP 8: UI SETUP ---
echo ">>> Installing Node.js..."
apt-get update -qq
apt-get purge nodejs -y 2>/dev/null
apt-get autoremove -y 2>/dev/null
apt-get install -y ca-certificates curl gnupg

mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

apt-get update -qq
apt-get install nodejs -y

echo ">>> Building UI..."
cd /workspace/ai-toolkit/ui
rm -rf node_modules .next dist
npm install
npm run update_db
npm run build

echo "========================================================"
echo "   INSTALLATION SUCCESSFUL"
echo "========================================================"
echo "1. Run: conda deactivate" 
echo "2. Run: conda activate toolkit"
echo "3. Run: cd /workspace/ai-toolkit/ui && npm run start"
echo "========================================================"
