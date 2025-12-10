#!/bin/bash

# ==========================================
# Ostris AI Toolkit - Simplified Installer
# PRE-REQUISITE: You MUST be in (toolkit) env
# ==========================================

# --- STEP 1: SAFETY CHECK ---
echo ">>> Checking Environment..."
PY_VER=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

if [ "$PY_VER" != "3.10" ]; then
    echo "CRITICAL ERROR: You are running Python $PY_VER."
    echo "You must manually run: 'conda activate toolkit' before this script."
    exit 1
fi
echo ">>> Environment OK: Python $PY_VER"

# --- STEP 2: CLONE REPO ---
cd /workspace
echo ">>> Cloning Ostris AI Toolkit..."
rm -rf ai-toolkit
git clone --depth 1 https://github.com/ostris/ai-toolkit
cd ai-toolkit

# --- STEP 3: GENERATE REQUIREMENTS (50-Series / 40-Series) ---
echo ">>> Writing Custom Requirements..."
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

# --- STEP 4: INSTALL DEPENDENCIES ---
echo ">>> Installing Dependencies..."
pip install --upgrade pip

# 1. Install Torch Stack (Explicitly 2.8.0)
echo ">>> Installing Torch 2.8.0..."
pip install "torch==2.8.0" torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129

# 2. Install Wheels
echo ">>> Installing Custom Wheels..."
pip install -r requirements.txt

# 3. Patch Transformers (Fix Hub Conflict)
echo ">>> Patching Libraries..."
pip install -U transformers diffusers accelerate peft huggingface_hub[cli] protobuf --extra-index-url https://download.pytorch.org/whl/cu129

# --- STEP 5: UI SETUP (Node.js) ---
echo ">>> Installing Node.js..."
# Note: apt-get uses sudo implicitly as root, or fails if not root (cloud usually root)
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
echo "1. Login to HuggingFace:  huggingface-cli login"
echo "2. Start the UI:          cd /workspace/ai-toolkit/ui && npm run start"
echo "========================================================"
