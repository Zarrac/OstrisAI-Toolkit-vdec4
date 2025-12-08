

***

# Ostris AI Toolkit vDec4 (RTX 50 & 40 Series)

This repository contains a **one-click installation script** for the [Ostris AI Toolkit](https://github.com/ostris/ai-toolkit). 

It is specifically patched and optimized for **NVIDIA RTX 50-series (Blackwell)** and **RTX 40-series** GPUs running on Linux. It handles the complex dependency conflicts that occur with bleeding-edge hardware.

## 🚀 Compatibility
| Hardware | Status | Notes |
| :--- | :--- | :--- |
| **RTX 5090 / 5080** | ✅ Supported | Uses CUDA 12.9 & PyTorch 2.8.0 Nightly |
| **RTX 4090 / 4080** | ✅ Supported | Fully optimized |
| **RTX 4070 Ti Super** | ✅ Supported | Includes VRAM fragmentation fixes |

## ✨ Features
This script automates the entire setup process on a fresh Linux instance:
1.  **Environment Setup:** Creates a clean Conda environment with **Python 3.10** (Required for pre-compiled wheels).
2.  **Bleeding Edge Deps:** Installs **PyTorch 2.8.0 Nightly**, `torchvision`, and `torchaudio` correctly to support CUDA 12.9.
3.  **Conflict Resolution:**
    *   Fixes `ModuleNotFoundError: No module named 'torchaudio'`.
    *   Fixes `huggingface-hub` version incompatibility with Transformers.
4.  **VRAM Optimization:** Automatically applies `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True` to prevent memory fragmentation crashes on 16GB cards.
5.  **UI Setup:** Installs Node.js v22, updates the database, and builds the web UI.

## 📥 Installation

Run this single command in your terminal:

```bash
wget https://raw.githubusercontent.com/Zarrac/OstrisAI-Toolkit-vdec4/main/install.sh && bash install.sh
```

## ⚙️ Post-Install Configuration

### 1. Optimize for your GPU (Important)
After installation, when configuring your training JSON file, adjust the `low_vram` setting based on your card:

*   **For 16GB Cards (RTX 5080, 4070 Ti Super):**
    You **MUST** set this to true to avoid OOM errors.
    ```json
    "model": {
        "low_vram": true
    }
    ```

*   **For 24GB+ Cards (RTX 5090, 4090):**
    Set this to false for maximum speed.
    ```json
    "model": {
        "low_vram": false
    }
    ```

### 2. Start the Toolkit
1.  Activate the environment:
    ```bash
    conda activate toolkit
    ```
2.  Login to HuggingFace (Required for downloading Flux):
    ```bash
    huggingface-cli login
    ```
3.  Start the UI:
    ```bash
    cd /workspace/ai-toolkit/ui
    npm run start
    ```

## 🛠️ What the script fixes (Technical Details)
*   **Torch 2.8.0:** The script forces an install of the nightly build to support the latest GPU architectures (Blackwell).
*   **Custom Wheels:** It writes a temporary `requirements.txt` to pull Flash Attention and Xformers specifically compiled for `cp310` (Python 3.10) on Linux.
*   **Transformers Patch:** It forces an update of `transformers` and `diffusers` to ensure compatibility with `huggingface-hub >= 0.24.0`.

## Credits
*   Original Toolkit: [ostris/ai-toolkit](https://github.com/ostris/ai-toolkit)
*   Wheels provided by: [MonsterMMORPG](https://huggingface.co/MonsterMMORPG)
