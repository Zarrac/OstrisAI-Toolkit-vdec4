#!/bin/bash

# ==========================================
# Ostris AI Toolkit - 50-Series Installer
# Compatible: RTX 4070 Ti Super & RTX 5080
# Environment: Conda + Python 3.10 + Torch 2.8 Nightly
# ==========================================

# --- STEP 1: Configure Conda Environment ---
echo ">>> Setting up Conda environment..."

# Source Conda
source /root/miniconda3/etc/profile.d/conda.sh 2>/dev/null || source /opt/conda/etc/profile.d/conda.sh 2>/dev/null || source ~/miniconda3/etc/profile.d/conda.sh

# Clean slate
conda deactivate
conda env remove -n toolkit -y

# Create new env with Python 3.10 (Strict requirement)
conda create -n toolkit python=3.10 -y
conda activate toolkit

# --- STEP 2: Clone Repository ---
cd /workspace
echo ">>> Cloning Ostris AI Toolkit..."
rm -rf ai-toolkit
git clone --depth 1 https://github.com/ostris/ai-toolkit
cd ai-toolkit

# --- STEP 3: Create Custom Requirements File ---
echo ">>> Writing custom requirements for 50-Series..."

# We overwrite the default requirements with your specific list
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

# --- STEP 4: Install Dependencies ---
echo ">>> Installing Python Requirements..."
python -m pip install --upgrade pip

# 1. Install Torch Stack FIRST (Explicitly Torch 2.8.0 + Audio)
echo ">>> Installing Torch 2.8.0 / Vision / Audio..."
pip install "torch==2.8.0" torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129

# 2. Install the custom requirements file we just created
echo ">>> Installing Custom Wheels..."
pip install -r requirements.txt

# 3. Patch Transformers & Diffusers (Fixes 'huggingface-hub' conflict)
echo ">>> Patching library versions..."
pip install -U transformers diffusers accelerate peft huggingface_hub[cli] protobuf --extra-index-url https://download.pytorch.org/whl/cu129

# --- STEP 5: Apply Permanent Memory Fixes ---
echo ">>> Applying VRAM fragmentation fixes to Conda Env..."
conda env config vars set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:512 -n toolkit

# --- STEP 6: Install Node.js v22 (For UI) ---
echo ">>> Installing Node.js v22..."
apt-get update
apt-get purge nodejs -y 2>/dev/null
apt-get autoremove -y 2>/dev/null
apt-get install -y ca-certificates curl gnupg

# Add NodeSource Repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Install Node
apt-get update
apt-get install nodejs -y

# --- STEP 7: Build the UI ---
echo ">>> Building AI Toolkit UI..."
cd /workspace/ai-toolkit/ui

# Clean and Build
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
