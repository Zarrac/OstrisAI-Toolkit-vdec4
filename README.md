Here is a clean, professional `README.md` for your GitHub repository. It explains exactly how to use the script and highlights that it is optimized for 40-series cards (like your 4070 Ti Super).

You can create a file named `README.md` in your repo and paste this content in.

***

# Ostris AI Toolkit - Optimized Installer (RTX 40-Series)

This repository contains a **one-click installation script** for the [Ostris AI Toolkit](https://github.com/ostris/ai-toolkit), specifically optimized for **NVIDIA RTX 40-series** GPUs (e.g., 4070 Ti Super, 4090).

It solves common installation headaches by handling environment creation, dependency conflicts, and VRAM optimization automatically.

## 🚀 Compatibility

| Hardware | Status | Notes |
| :--- | :--- | :--- |
| **RTX 4070 Ti Super** | ✅ Verified | Includes VRAM fragmentation fixes |
| **RTX 4090 / 4080** | ✅ Supported | Full performance mode |
| **RTX 30-Series** | ✅ Supported | Uses standard CUDA 12.4 |
| **RTX 50-Series** | ⚠️ Use Nightly | *Use the 50-series specific script for Blackwell support* |

## ✨ Features

*   **Automated Environment:** Creates a clean Conda environment named `toolkit` with Python 3.10.
*   **Stable PyTorch:** Installs the standard Torch (CUDA 12.4) rather than experimental builds.
*   **Dependency Fixes:** Automatically installs missing utilities that often break the default install (`oyaml`, `prodict`, `dotenv`, `cv2`).
*   **Memory Optimization:** Sets `PYTORCH_CUDA_ALLOC_CONF` to prevent "Out of Memory" crashes on 16GB cards.
*   **Safety Lock:** Uses direct pathing to ensure dependencies are never installed into the wrong Conda environment (`base`/`main`).

## 📥 Installation

Run this single command in your Linux terminal (works on Cloud Instances like RunPod, Vast.ai, etc.):

```bash
wget -O install.sh https://raw.githubusercontent.com/Zarrac/OstrisAI-Toolkit-vdec4/main/install.sh && bash install.sh
```

## 🛠️ How to Use

Once the installation finishes, follow these steps to start training:

### 1. Activate the Environment
You must activate the toolkit environment to use it.
```bash
conda activate toolkit
```

### 2. Start the UI
Navigate to the UI folder and start the web interface:
```bash
cd /workspace/ai-toolkit/ui
npm run start
```

*   **Toolkit:** [ostris/ai-toolkit](https://github.com/ostris/ai-toolkit)

