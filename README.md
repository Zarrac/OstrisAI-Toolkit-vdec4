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

```bash
wget https://raw.githubusercontent.com/Zarrac/OstrisAI-Toolkit-vdec4/main/install.sh && bash install.sh
