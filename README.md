# 🎬 Article2Video — AI Text-to-Video Generation Platform

> Convert any news article or PIB press release into a professional MP4 video automatically using AI — with scene images, voice narration, and subtitles.

![Python](https://img.shields.io/badge/Python-3.10%2B-blue?style=flat-square&logo=python)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=flat-square&logo=fastapi)
![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=flat-square&logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

---

## 📸 What It Does

Paste any news article → AI breaks it into scenes → generates images for each scene → adds voice narration → renders a complete downloadable MP4 video.

```
Article Text
     │
     ▼
[AI Summarizer]   →  Splits article into N scenes with image prompts
     │                (OpenAI GPT-3.5 or free extractive fallback)
     ▼
[Image Generator] →  Creates one image per scene
     │                (HuggingFace SDXL → DALL-E 3 → PIL placeholder)
     ▼
[TTS Engine]      →  Synthesizes voice narration per scene
     │                (OpenAI TTS → gTTS free fallback)
     ▼
[Video Renderer]  →  Assembles all scenes + audio + subtitles → MP4
                      (MoviePy + FFmpeg)
```

---

## 📁 Project Structure

```
article2video/
├── README.md
├── .gitignore
│
├── backend/                        # Python FastAPI Backend
│   ├── main.py                     # App entry point
│   ├── requirements.txt            # Python dependencies
│   ├── .env.example                # Environment variable template
│   │
│   ├── api/
│   │   ├── __init__.py
│   │   └── routes.py               # REST API endpoints
│   │
│   ├── models/
│   │   ├── __init__.py
│   │   └── schemas.py              # Pydantic request/response models
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── pipeline.py             # Main orchestrator
│   │   ├── summarizer.py           # AI scene generation
│   │   ├── image_generator.py      # Image generation (HF/DALL-E/PIL)
│   │   ├── tts_service.py          # Text-to-speech
│   │   └── video_renderer.py       # MoviePy video assembly
│   │
│   └── utils/
│       ├── __init__.py
│       ├── job_store.py            # In-memory job tracker
│       └── logger.py               # Logging setup
│
└── frontend/                       # Flutter Frontend
    ├── pubspec.yaml                # Flutter dependencies
    └── lib/
        ├── main.dart               # App entry + theme
        ├── screens/
        │   └── home_screen.dart    # Main screen
        ├── widgets/
        │   ├── article_input_widget.dart
        │   ├── processing_widget.dart
        │   ├── result_widget.dart
        │   └── options_widget.dart
        ├── models/
        │   ├── job_model.dart
        │   └── video_options_model.dart
        └── services/
            ├── api_service.dart
            └── video_provider.dart
```

---

## 🚀 Setup & Installation

### Prerequisites

| Tool | Version | Download |
|------|---------|----------|
| Python | 3.10+ | https://python.org |
| FFmpeg | Any | https://www.gyan.dev/ffmpeg/builds/ |
| Flutter | 3.x+ | https://docs.flutter.dev/get-started/install |
| Git | Any | https://git-scm.com |

---

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/article2video.git
cd article2video
```

---

### 2. Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate — Windows:
venv\Scripts\activate
# Activate — macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### Configure API Keys (all optional)

```bash
copy .env.example .env        # Windows
cp .env.example .env          # macOS/Linux
```

| Key | Used For | Free? |
|-----|---------|-------|
| `OPENAI_API_KEY` | GPT summarization + DALL-E + TTS | No |
| `HUGGINGFACE_TOKEN` | Stable Diffusion XL images | Yes (limited) |
| *(no keys)* | Extractive NLP + PIL images + gTTS | ✅ Fully free |

#### Start the Server

```bash
python main.py
```

- API: `http://localhost:8000`
- Swagger Docs: `http://localhost:8000/docs`

---

### 3. Frontend Setup

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

> Edit `lib/services/api_service.dart` → change `baseUrl` if backend is on a different machine.

---

## 🌐 REST API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/generate` | Submit article → get `job_id` |
| GET | `/api/v1/status/{job_id}` | Poll progress 0–100% |
| GET | `/api/v1/download/{job_id}` | Download MP4 |
| GET | `/health` | Health check |

### Quick Test (PowerShell)

```powershell
Invoke-WebRequest -Uri "http://localhost:8000/health" -Method GET
```

---

## 🔧 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter + Provider |
| Backend | Python FastAPI + Uvicorn |
| Summarization | OpenAI GPT-3.5 / Extractive NLP |
| Image Generation | HuggingFace SDXL / DALL-E 3 / PIL |
| Text-to-Speech | OpenAI TTS / gTTS |
| Video Assembly | MoviePy + FFmpeg |

---

## 🛠 Windows Notes

- FFmpeg: extract `ffmpeg-release-essentials.zip` → add `bin` folder to System PATH
- Activate venv with `venv\Scripts\activate`
- Use Swagger UI at `/docs` instead of curl

---

## 📄 License

MIT License — free to use and modify.
