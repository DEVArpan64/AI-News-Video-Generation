"""
API Routes - All REST endpoints for the video generation pipeline
"""

import uuid
import asyncio
from fastapi import APIRouter, HTTPException, BackgroundTasks
from fastapi.responses import FileResponse

from models.schemas import ArticleRequest, JobStatus, JobResponse
from services.pipeline import VideoPipeline
from utils.job_store import job_store
from utils.logger import setup_logger

logger = setup_logger(__name__)
router = APIRouter()
pipeline = VideoPipeline()


@router.post("/generate", response_model=JobResponse)
async def generate_video(request: ArticleRequest, background_tasks: BackgroundTasks):
    """
    Submit an article for video generation.
    Returns a job_id to track progress.
    """
    job_id = str(uuid.uuid4())
    job_store.create(job_id)
    background_tasks.add_task(pipeline.run, job_id, request.article_text, request.options)
    logger.info(f"Job {job_id} queued")
    return JobResponse(job_id=job_id, message="Video generation started")


@router.get("/status/{job_id}", response_model=JobStatus)
async def get_status(job_id: str):
    """Poll job status and progress."""
    job = job_store.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    return job


@router.get("/download/{job_id}")
async def download_video(job_id: str):
    """Download the generated MP4 video."""
    job = job_store.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    if job.status != "completed":
        raise HTTPException(status_code=400, detail=f"Video not ready. Status: {job.status}")
    if not job.video_path:
        raise HTTPException(status_code=500, detail="Video file missing")
    return FileResponse(
        job.video_path,
        media_type="video/mp4",
        filename=f"article2video_{job_id[:8]}.mp4"
    )


@router.get("/jobs")
async def list_jobs():
    """List all jobs (for debugging)."""
    return {"jobs": job_store.list_all()}
