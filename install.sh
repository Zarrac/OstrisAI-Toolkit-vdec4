#!/bin/bash

# ==========================================
# Ostris AI Toolkit - 50-Series Installer (Robust Version)
# Compatible: RTX 4070 Ti Super & RTX 5080
# Fixes: Python 3.12 Mismatch / Activation Issues
# ==========================================

# --- STEP 1: FORCE CONDA INITIALIZATION ---
echo ">>> Initializing Conda..."
# Try to find conda and initialize the shell hook
eval "$(/opt/conda/bin/conda shell.bash hook)" 2>/dev/null || \
eval "$(/root/miniconda3/bin/conda shell.bash hook)" 2>/dev/null || \
eval "$(conda shell.bash hook)" 2>/dev/null

# --- STEP 2: SETUP ENVIRONMENT ---
echo ">>> Setting up Conda environment..."

# Deactivate main/base just in case
conda deactivate

# Remove old toolkit env if exists
conda env remove -n toolkit -y

# Create new env with Python 3.10 (REQUIRED)
conda create -n toolkit python=3.10 -y

# ACTIVATE AND VERIFY
conda activate toolkit

# CHECK: If python version is not 3.10, stop immediately
PY_VER=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
if [ "$PY_VER" != "3.10" ]; then
    echo "ERROR: Failed to activate Python 3.10 environment."
    echo "Current version is: $PY_VER"
    echo "Please run: 'conda activate toolkit' manually and then run the pip commands."
    exit 1
fi
echo ">>> Environment Verified: Python $PY_VER (Correct)"

# --- STEP 3: Clone Repository ---
cd /workspace
echo ">>> Cloning Ostris AI Toolkit..."
rm -rf ai-toolkit
git clone --depth 1 https://github.com/ostris/ai-toolkit
cd ai-toolkit

# --- STEP 4: Create Custom Requirements File ---
echo ">>> Writing custom requirements for 50-Series..."
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

# --- STEP 5: Install Dependencies ---
echo ">>> Installing Python Requirements..."
python -m pip install --upgrade pip

# 1. Install Torch Stack FIRST
echo ">>> Installing Torch 2.8.0 / Vision / Audio..."
pip install "torch==2.8.0" torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129

# 2. Install Custom Wheels
echo ">>> Installing Custom Wheels..."
pip install -r requirements.txt

# 3. Patch Transformers
echo ">>> Patching library versions..."
pip install -U transformers diffusers accelerate peft huggingface_hub[cli] protobuf --extra-index-url https://download.pytorch.org/whl/cu129

# --- STEP 6: Apply Permanent Memory Fixes ---
echo ">>> Applying VRAM fragmentation fixes..."
conda env config vars set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:512 -n toolkit

# --- STEP 7: Install Node.js v22 (For UI) ---
echo ">>> Installing Node.js v22..."
apt-get update
apt-get purge nodejs -y 2>/dev/null
apt-get autoremove -y 2>/dev/null
apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install nodejs -y

# --- STEP 8: Build the UI ---
echo ">>> Building AI Toolkit UI..."
cd /workspace/ai-toolkit/ui
rm -rf node_modules .next dist
npm install
npm run update_db
npm run build

echo "========================================================"
echo "   INSTALLATION COMPLETE"
echo "========================================================"
echo "1. Activate environment:  conda activate toolkit"
echo "2. Login to HuggingFace:  huggingface-cli login"
echo "3. Start the UI:          cd /workspace/ai-toolkit/ui && npm run start"
echo "========================================================"
