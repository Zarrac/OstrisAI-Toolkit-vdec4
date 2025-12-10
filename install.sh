#!/bin/bash

# ==========================================
# Ostris AI Toolkit - 50-Series Installer
# Method: Force Conda Activation
# ==========================================

# --- STEP 1: FORCE CONDA INITIALIZATION ---
echo ">>> Initializing Conda..."
# This block forces the script to "see" Conda
eval "$(/opt/conda/bin/conda shell.bash hook)" 2>/dev/null || \
eval "$(/root/miniconda3/bin/conda shell.bash hook)" 2>/dev/null || \
eval "$(conda shell.bash hook)" 2>/dev/null

# --- STEP 2: SETUP ENVIRONMENT ---
echo ">>> Setting up Conda environment..."

# 1. Clean up
conda deactivate 2>/dev/null
conda env remove -n toolkit -y 2>/dev/null

# 2. Create Python 3.10 Env (Required for wheels)
conda create -n toolkit python=3.10 -y

# 3. Activate
conda activate toolkit

# 4. Verify Activation
PY_VER=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
if [ "$PY_VER" != "3.10" ]; then
    echo "----------------------------------------------------"
    echo "CRITICAL ERROR: Environment did not switch to 3.10!"
    echo "Current Python: $PY_VER"
    echo "Please run this command instead: source install.sh"
    echo "----------------------------------------------------"
    exit 1
fi
echo ">>> Environment Verified: Python $PY_VER (Success)"

# --- STEP 3: Clone Repository ---
cd /workspace
rm -rf ai-toolkit
git clone --depth 1 https://github.com/ostris/ai-toolkit
cd ai-toolkit

# --- STEP 4: WRITE CUSTOM REQUIREMENTS (For 50-Series) ---
echo ">>> Writing Optimized Requirements..."
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

# --- STEP 5: INSTALL ---
echo ">>> Installing Dependencies..."
python -m pip install --upgrade pip

# Install Torch Stack First
pip install "torch==2.8.0" torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129

# Install Custom Wheels
pip install -r requirements.txt

# Patch Transformers
pip install -U transformers diffusers accelerate peft huggingface_hub[cli] protobuf --extra-index-url https://download.pytorch.org/whl/cu129

# --- STEP 6: MEMORY FIXES ---
conda env config vars set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:512 -n toolkit

# --- STEP 7: UI SETUP ---
echo ">>> Setting up UI..."
# Node install
apt-get update && apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update && apt-get install nodejs -y

# Build
cd ui
rm -rf node_modules .next dist
npm install
npm run update_db
npm run build

echo ">>> DONE. Run: conda activate toolkit"
