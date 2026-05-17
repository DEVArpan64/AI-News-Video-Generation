"""
Video Generation Pipeline
Orchestrates: Summarize → Images → TTS → Render
Updates job store at each step for real-time status.
"""

import os
from utils.job_store import job_store
from utils.logger import setup_logger
from models.schemas import SceneData, VideoOptions
from services.summarizer import SummarizationService
from services.image_generator import ImageGenerationService
from services.tts_service import TTSService
from services.video_renderer import VideoRenderer

logger = setup_logger(__name__)

summarizer = SummarizationService()
image_gen = ImageGenerationService()
tts_service = TTSService()
renderer = VideoRenderer()


class VideoPipeline:
    async def run(self, job_id: str, article_text: str, options: VideoOptions):
        """Full pipeline. Runs in background task."""
        try:
            base_dir = f"outputs/{job_id}"
            os.makedirs(f"{base_dir}/images", exist_ok=True)
            os.makedirs(f"{base_dir}/audio", exist_ok=True)

            # ── Step 1: Summarize ──────────────────────────────────────────
            self._update(job_id, 10, "processing", "Analyzing article & generating scenes...")
            raw_scenes = summarizer.summarize_to_scenes(article_text, options.max_scenes)
            logger.info(f"Job {job_id}: {len(raw_scenes)} scenes generated")

            scene_objects = []
            for i, s in enumerate(raw_scenes):
                scene_objects.append(SceneData(
                    index=i,
                    text=s["text"],
                    image_prompt=s["image_prompt"],
                ))
            job_store.update(job_id, scenes=scene_objects)

            # ── Step 2: Generate Images ────────────────────────────────────
            self._update(job_id, 25, "processing", "Generating scene images...")
            for i, scene in enumerate(scene_objects):
                img_path = f"{base_dir}/images/scene_{i}.png"
                try:
                    image_gen.generate(scene.image_prompt, img_path)
                    scene.image_path = img_path
                except Exception as e:
                    logger.error(f"Image gen failed scene {i}: {e}")
                progress = 25 + int((i + 1) / len(scene_objects) * 30)
                self._update(job_id, progress, "processing", f"Image {i+1}/{len(scene_objects)} done")

            # ── Step 3: Text-to-Speech ─────────────────────────────────────
            self._update(job_id, 55, "processing", "Synthesizing voice narration...")
            for i, scene in enumerate(scene_objects):
                audio_path = f"{base_dir}/audio/scene_{i}.mp3"
                try:
                    tts_service.synthesize(scene.text, audio_path, lang=options.voice)
                    scene.audio_path = audio_path
                except Exception as e:
                    logger.error(f"TTS failed scene {i}: {e}")
                progress = 55 + int((i + 1) / len(scene_objects) * 20)
                self._update(job_id, progress, "processing", f"Audio {i+1}/{len(scene_objects)} done")

            # ── Step 4: Render Video ───────────────────────────────────────
            self._update(job_id, 80, "processing", "Rendering final video...")
            video_path = f"{base_dir}/output.mp4"
            scene_dicts = [
                {"image_path": s.image_path, "audio_path": s.audio_path, "text": s.text}
                for s in scene_objects
            ]
            renderer.render(
                scene_dicts,
                video_path,
                add_subtitles=options.add_subtitles,
                duration_per_scene=options.duration_per_scene,
            )

            # ── Done ───────────────────────────────────────────────────────
            video_url = f"/outputs/{job_id}/output.mp4"
            job_store.update(
                job_id,
                status="completed",
                progress=100,
                current_step="Video ready!",
                video_path=video_path,
                video_url=video_url,
                scenes=scene_objects,
            )
            logger.info(f"Job {job_id} completed successfully")

        except Exception as e:
            logger.error(f"Pipeline failed for job {job_id}: {e}")
            job_store.update(job_id, status="failed", error=str(e), current_step="Failed")

    def _update(self, job_id, progress, status, step):
        job_store.update(job_id, progress=progress, status=status, current_step=step)
