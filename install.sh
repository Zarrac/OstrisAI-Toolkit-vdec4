#!/bin/bash

# ==========================================
# Ostris AI Toolkit - 50-Series Installer
# Logic: Exit Main -> Create Toolkit -> Install
# ==========================================

# --- STEP 1: GET OUT OF MAIN ---
echo ">>> Detecting Conda configuration..."

# We use the currently active 'main' just to find where Conda lives
CONDA_BASE=$(conda info --base)

if [ -z "$CONDA_BASE" ]; then
    echo "CRITICAL ERROR: Could not find Conda."
    exit 1
fi

echo ">>> Found Conda at: $CONDA_BASE"

# Now we enable Conda commands for this script
source "$CONDA_BASE/etc/profile.d/conda.sh"

# IMMEDIATE DEACTIVATE
# We run this twice to ensure we are completely out of 'main' or 'base'
echo ">>> Exiting '(main)' environment..."
conda deactivate
conda deactivate

# --- STEP 2: CREATE FRESH ENVIRONMENT ---
echo ">>> Creating 'toolkit' environment (Python 3.10)..."

# Remove old one if exists
conda env remove -n toolkit -y 2>/dev/null

# Create new one
conda create -n toolkit python=3.10 -y

# --- STEP 3: SETUP PATHS (The Safety Lock) ---
# Instead of trusting 'conda activate', we point straight to the binary.
# This makes it impossible to accidentally install in 'main'.
TK_PYTHON="$CONDA_BASE/envs/toolkit/bin/python"
TK_PIP="$CONDA_BASE/envs/toolkit/bin/pip"

# Verify
if [ ! -f "$TK_PIP" ]; then
    echo "ERROR: The toolkit environment was not created correctly."
    exit 1
fi

echo ">>> Targeted Installation Path: $TK_PIP"

# --- STEP 4: CLONE REPO ---
cd /workspace
rm -rf ai-toolkit
git clone --depth 1 https://github.com/ostris/ai-toolkit
cd ai-toolkit

# --- STEP 5: WRITE REQUIREMENTS ---
echo ">>> Generating 50-Series Requirements..."
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

# --- STEP 6: INSTALL ---
echo ">>> Installing dependencies..."

# Upgrade
