"""
Video Renderer
Assembles images + audio + subtitles into final MP4 using MoviePy.
"""

import os
from typing import List
from utils.logger import setup_logger

logger = setup_logger(__name__)


class VideoRenderer:
    def __init__(self):
        self.fps = 24
        self.resolution = (1280, 720)

    def render(
        self,
        scenes: List[dict],
        output_path: str,
        add_subtitles: bool = True,
        duration_per_scene: int = 4,
    ) -> str:
        """
        Render final video from scene data.
        scenes: list of {image_path, audio_path, text}
        """
        try:
            from moviepy.editor import (
                ImageClip, AudioFileClip, TextClip,
                CompositeVideoClip, concatenate_videoclips,
            )
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            clips = []

            for i, scene in enumerate(scenes):
                img_path = scene.get("image_path")
                audio_path = scene.get("audio_path")
                text = scene.get("text", "")

                if not img_path or not os.path.exists(img_path):
                    logger.warning(f"Scene {i}: missing image, skipping")
                    continue

                # Get duration from audio or use default
                duration = duration_per_scene
                if audio_path and os.path.exists(audio_path):
                    try:
                        audio = AudioFileClip(audio_path)
                        duration = max(audio.duration, 2)
                    except Exception:
                        duration = duration_per_scene

                # Create image clip
                img_clip = ImageClip(img_path).set_duration(duration)
                img_clip = img_clip.resize(self.resolution)

                # Add audio
                if audio_path and os.path.exists(audio_path):
                    try:
                        audio = AudioFileClip(audio_path).subclip(0, duration)
                        img_clip = img_clip.set_audio(audio)
                    except Exception as e:
                        logger.warning(f"Audio attach failed for scene {i}: {e}")

                # Add subtitle overlay
                if add_subtitles and text:
                    try:
                        subtitle = self._make_subtitle(text, duration)
                        img_clip = CompositeVideoClip([img_clip, subtitle])
                    except Exception as e:
                        logger.warning(f"Subtitle failed for scene {i}: {e}")

                clips.append(img_clip)

            if not clips:
                raise ValueError("No valid scenes to render")

            # Concatenate all scene clips
            final = concatenate_videoclips(clips, method="compose")
            final.write_videofile(
                output_path,
                fps=self.fps,
                codec="libx264",
                audio_codec="aac",
                logger=None,  # suppress verbose moviepy logs
            )
            logger.info(f"Video rendered: {output_path}")
            return output_path

        except Exception as e:
            logger.error(f"Video rendering failed: {e}")
            raise

    def _make_subtitle(self, text: str, duration: float):
        """Create a subtitle TextClip positioned at the bottom."""
        from moviepy.editor import TextClip
        # Truncate long text
        short = text if len(text) <= 100 else text[:97] + "..."
        try:
            clip = (
                TextClip(
                    short,
                    fontsize=28,
                    color="white",
                    bg_color="rgba(0,0,0,0.6)",
                    font="DejaVu-Sans",
                    size=(1200, None),
                    method="caption",
                )
                .set_position(("center", 640))
                .set_duration(duration)
            )
            return clip
        except Exception:
            # Fallback without bg_color transparency
            return (
                TextClip(short, fontsize=24, color="white", size=(1200, None), method="caption")
                .set_position(("center", 640))
                .set_duration(duration)
            )
