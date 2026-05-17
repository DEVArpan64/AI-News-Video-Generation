"""
Image Generation Service
Supports: HuggingFace Stable Diffusion, OpenAI DALL-E, or placeholder fallback.
"""

import os
import requests
from pathlib import Path
from utils.logger import setup_logger

logger = setup_logger(__name__)


class ImageGenerationService:
    def __init__(self):
        self.hf_token = os.getenv("HUGGINGFACE_TOKEN", "")
        self.openai_key = os.getenv("OPENAI_API_KEY", "")
        # HF Inference API - free tier available
        self.hf_url = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"

    def generate(self, prompt: str, output_path: str) -> str:
        """Generate an image from prompt. Returns saved file path."""
        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        if self.hf_token:
            return self._huggingface(prompt, output_path)
        elif self.openai_key:
            return self._dalle(prompt, output_path)
        else:
            return self._placeholder(prompt, output_path)

    def _huggingface(self, prompt: str, output_path: str) -> str:
        """HuggingFace Stable Diffusion via Inference API."""
        try:
            enhanced = f"{prompt}, high quality, sharp, professional"
            response = requests.post(
                self.hf_url,
                headers={"Authorization": f"Bearer {self.hf_token}"},
                json={"inputs": enhanced[:500]},
                timeout=60,
            )
            if response.status_code == 200:
                with open(output_path, "wb") as f:
                    f.write(response.content)
                logger.info(f"HF image saved: {output_path}")
                return output_path
            else:
                logger.warning(f"HF API error {response.status_code}. Using placeholder.")
                return self._placeholder(prompt, output_path)
        except Exception as e:
            logger.warning(f"HF failed: {e}. Using placeholder.")
            return self._placeholder(prompt, output_path)

    def _dalle(self, prompt: str, output_path: str) -> str:
        """OpenAI DALL-E 3 image generation."""
        try:
            import openai
            client = openai.OpenAI(api_key=self.openai_key)
            response = client.images.generate(
                model="dall-e-3",
                prompt=prompt[:1000],
                size="1024x576",
                quality="standard",
                n=1,
            )
            img_url = response.data[0].url
            img_data = requests.get(img_url, timeout=30).content
            with open(output_path, "wb") as f:
                f.write(img_data)
            return output_path
        except Exception as e:
            logger.warning(f"DALL-E failed: {e}. Using placeholder.")
            return self._placeholder(prompt, output_path)

    def _placeholder(self, prompt: str, output_path: str) -> str:
        """
        Generate a styled placeholder image using PIL.
        Used when no API keys are configured.
        """
        try:
            from PIL import Image, ImageDraw, ImageFont
            import textwrap

            # Create a gradient-like background
            img = Image.new("RGB", (1280, 720), color=(15, 23, 42))
            draw = ImageDraw.Draw(img)

            # Draw gradient overlay
            for y in range(720):
                alpha = int(y / 720 * 40)
                draw.line([(0, y), (1280, y)], fill=(30 + alpha, 50 + alpha, 80 + alpha))

            # Add decorative elements
            draw.rectangle([0, 0, 1280, 4], fill=(99, 102, 241))
            draw.rectangle([0, 716, 1280, 720], fill=(99, 102, 241))

            # Add text
            short_text = textwrap.fill(prompt[:120], width=50)
            try:
                font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 28)
                small_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
            except Exception:
                font = ImageFont.load_default()
                small_font = font

            # Label
            draw.text((640, 280), "AI GENERATED SCENE", font=font, fill=(99, 102, 241), anchor="mm")
            draw.text((640, 380), short_text, font=small_font, fill=(200, 210, 230), anchor="mm")

            img.save(output_path, "PNG")
            logger.info(f"Placeholder image saved: {output_path}")
            return output_path
        except Exception as e:
            logger.error(f"Placeholder generation failed: {e}")
            raise
