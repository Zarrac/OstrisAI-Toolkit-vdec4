#!/bin/bash

# ==========================================
# Ostris AI Toolkit - 50-Series Installer (Bulletproof)
# Method: Direct Path Execution (Impossible to hit 'main')
# ==========================================

# --- STEP 1: LOCATE CONDA & PREPARE ---
echo ">>> initializing..."

# Find Conda Base Path
if [ -d "/opt/conda" ]; then
    CONDA_BASE="/opt/conda"
elif [ -d "$HOME/miniconda3" ]; then
    CONDA_BASE="$HOME/miniconda3"
elif [ -d "/root/miniconda3" ]; then
    CONDA_BASE="/root/miniconda3"
else
    echo "Could not find Conda installation. Exiting."
    exit 1
fi

# Enable Conda commands for this script
source "$CONDA_BASE/etc/profile.d/conda.sh"

# Force deactivate 'main' inside this script context
conda deactivate
conda deactivate

echo ">>> Setting up 'toolkit' environment..."
# Remove old env
conda env remove -n toolkit -y 2>/dev/null

# Create new env
conda create -n toolkit python=3.10 -y

# DEFINE DIRECT PATHS (The Fix)
# We do not rely on 'activate'. We point directly to the binary.
TK_PYTHON="$CONDA_BASE/envs/toolkit/bin/python"
TK_PIP="$CONDA_BASE/envs/toolkit/bin/pip"

# Verification
if [ ! -f "$TK_PIP" ]; then
    echo "CRITICAL ERROR: Could not locate pip at $TK_PIP"
    exit 1
fi

echo ">>> Installing into: $TK_PIP" 
# This proves we are not in main

# --- STEP 2: CLONE REPO ---
cd /workspace
rm -rf ai-toolkit
git clone --depth 1 https://github.com/ostris/ai-toolkit
cd ai-toolkit

# --- STEP 3: GENERATE REQUIREMENTS ---
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

# --- STEP 4: INSTALL DEPENDENCIES (Using TK_PIP) ---
echo ">>> Installing Python Packages..."

# Upgrade pip inside toolkit
"$TK_PYTHON" -m pip install --upgrade pip

# 1. Install Torch Stack (Directly to toolkit)
echo ">>> Installing Torch 2.8..."
"$TK_PIP" install "torch==2.8.0" torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129

# 2. Install Custom Wheels (Directly to toolkit)
echo ">>> Installing Custom Wheels..."
"$TK_PIP" install -r requirements.txt

# 3. Patch Transformers (Directly to toolkit)
echo ">>> Patching Transformers..."
"$TK_PIP" install -U transformers diffusers accelerate peft huggingface_hub[cli] protobuf --extra-index-url https://download.pytorch.org/whl/cu129

# --- STEP 5: MEMORY FIXES ---
echo ">>> Applying Memory Fixes..."
conda env config vars set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:512 -n toolkit

# --- STEP 6: UI SETUP ---
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
echo "Everything is installed in the 'toolkit' environment."
echo ""
echo "To start using it, run these commands manually:"
echo "1. conda deactivate" 
echo "2. conda activate toolkit"
echo "3. cd /workspace/ai-toolkit/ui && npm run start"
echo "========================================================"
