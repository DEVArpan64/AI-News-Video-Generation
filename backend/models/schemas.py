"""
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum


class VideoOptions(BaseModel):
    voice: str = Field(default="en", description="TTS language/voice")
    style: str = Field(default="news", description="Visual style: news | cinematic | minimal")
    duration_per_scene: int = Field(default=4, ge=2, le=10)
    add_subtitles: bool = True
    max_scenes: int = Field(default=5, ge=2, le=10)


class ArticleRequest(BaseModel):
    article_text: str = Field(..., min_length=50, description="News article or PIB text")
    options: VideoOptions = VideoOptions()


class SceneData(BaseModel):
    index: int
    text: str
    image_prompt: str
    image_path: Optional[str] = None
    audio_path: Optional[str] = None


class JobStatus(BaseModel):
    job_id: str
    status: str  # queued | processing | completed | failed
    progress: int = 0  # 0-100
    current_step: str = ""
    scenes: List[SceneData] = []
    video_path: Optional[str] = None
    video_url: Optional[str] = None
    error: Optional[str] = None


class JobResponse(BaseModel):
    job_id: str
    message: str
