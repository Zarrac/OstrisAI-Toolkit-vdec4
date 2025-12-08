

```markdown
# Ostris AI Toolkit - Automated Installer (RTX 50-Series Ready)

This repository contains an automated installation script designed to set up the **Ostris AI Toolkit** on Linux instances (Vast.ai, Local).

It is specifically optimized for **NVIDIA RTX 50-Series (Blackwell)** and **40-Series** GPUs, ensuring compatibility with the latest CUDA 12.9 drivers and PyTorch 2.8 Nightly.

## 🚀 Supported Hardware

| GPU Model | VRAM | Status | Configuration Note |
| :--- | :--- | :--- | :--- |
| **RTX 5090** | 32GB | ✅ Supported | Fastest Speed. Set `"low_vram": false` |
| **RTX 4090** | 24GB | ✅ Supported | Fast Speed. Set `"low_vram": false` |
| **RTX 5080** | 16GB | ✅ Supported | **Requires** `"low_vram": true` |
| **RTX 4070 Ti Super** | 16GB | ✅ Supported | **Requires** `"low_vram": true` |

## 📦 One-Line Installation

Run this command in your terminal. It handles everything (Conda setup, Dependencies, UI Build, Memory Fixes).

```
wget https://raw.githubusercontent.com/Zarrac/OstrisAI-Toolkit-vdec4/main/install.sh && bash install.sh```

## 🛠️ What This Script Does

1.  **Environment:** Creates a clean Conda environment named `toolkit` running **Python 3.10** (Strict requirement for custom wheels).
2.  **Core Stack:** Installs **PyTorch 2.8.0 Nightly** with **CUDA 12.9** (Required for RTX 50-Series).
3.  **Optimization:** Installs pre-compiled wheels for **Flash Attention**, **Xformers**, and **SageAttention**.
4.  **Fixes:**
    *   Patches `transformers` and `huggingface-hub` to prevent version conflicts.
    *   **Memory Fix:** Automatically sets `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:512` in the environment variable to prevent fragmentation crashes.
5.  **UI:** Installs Node.js v22, updates the database, and builds the Next.js UI.

## 🚦 Post-Install Usage

### 1. Activate the Environment
```bash
conda activate toolkit
```

### 2. Login to HuggingFace
Required to download Flux models. You need a Write token.
```bash
huggingface-cli login
```

### 3. Start the UI
```bash
cd /workspace/ai-toolkit/ui
npm run start
```
*Access the UI at `http://localhost:3000` (or your cloud instance IP).*

---

## ⚠️ Important Configuration Guide

To avoid **CUDA Out of Memory (OOM)** errors, you must configure your training job JSON file according to your GPU's VRAM.

### For 16GB Cards (RTX 5080 / 4070 Ti Super)
You **must** enable Low VRAM mode. This offloads parts of the model to CPU RAM when not in use.

In your training JSON config:
```json
"model": {
    "name_or_path": "ostris/Flex.1-alpha",
    "quantize": true,
    "low_vram": true,  <-- SET THIS TO TRUE
    ...
}
```

### For 24GB+ Cards (RTX 5090 / 4090)
You have enough VRAM to keep the model loaded. Disabling Low VRAM mode will result in **faster training speeds** (approx 10-20% boost).

In your training JSON config:
```json
"model": {
    "name_or_path": "ostris/Flex.1-alpha",
    "quantize": true,
    "low_vram": false, <-- SET THIS TO FALSE
    ...
}
```

## ❓ Troubleshooting

**Q: I see "CUDA error: out of memory" instantly.**
A: Check your JSON config. Did you set `"low_vram": true`? If you are on a 16GB card, this is mandatory.
