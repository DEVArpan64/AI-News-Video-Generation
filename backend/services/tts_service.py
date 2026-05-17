"""
Text-to-Speech Service
Uses gTTS (free, no API key needed) with OpenAI TTS as premium option.
"""

import os
from utils.logger import setup_logger

logger = setup_logger(__name__)


class TTSService:
    def __init__(self):
        self.openai_key = os.getenv("OPENAI_API_KEY", "")

    def synthesize(self, text: str, output_path: str, lang: str = "en") -> str:
        """Convert text to speech. Returns audio file path."""
        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        if self.openai_key:
            return self._openai_tts(text, output_path)
        return self._gtts(text, output_path, lang)

    def _gtts(self, text: str, output_path: str, lang: str) -> str:
        """Google TTS - free, no API key required."""
        try:
            from gtts import gTTS
            tts = gTTS(text=text[:500], lang=lang, slow=False)
            tts.save(output_path)
            logger.info(f"gTTS audio saved: {output_path}")
            return output_path
        except Exception as e:
            logger.error(f"gTTS failed: {e}")
            # Create silent audio as last resort
            return self._silent_audio(output_path)

    def _openai_tts(self, text: str, output_path: str) -> str:
        """OpenAI TTS - higher quality."""
        try:
            import openai
            client = openai.OpenAI(api_key=self.openai_key)
            response = client.audio.speech.create(
                model="tts-1",
                voice="alloy",
                input=text[:4096],
            )
            response.stream_to_file(output_path)
            return output_path
        except Exception as e:
            logger.warning(f"OpenAI TTS failed: {e}. Using gTTS.")
            return self._gtts(text, output_path, "en")

    def _silent_audio(self, output_path: str) -> str:
        """Create 3-second silent MP3 as fallback."""
        try:
            from pydub import AudioSegment
            silence = AudioSegment.silent(duration=3000)
            silence.export(output_path, format="mp3")
            return output_path
        except Exception:
            # Write minimal valid MP3 header
            with open(output_path, "wb") as f:
                f.write(b"\xff\xfb\x90\x00" * 100)
            return output_path
