"""
Summarization Service
Uses OpenAI GPT or falls back to simple extractive summarization.
"""

import os
import re
from typing import List
from utils.logger import setup_logger

logger = setup_logger(__name__)


class SummarizationService:
    def __init__(self):
        self.api_key = os.getenv("OPENAI_API_KEY", "")
        self.use_openai = bool(self.api_key)

    def summarize_to_scenes(self, article_text: str, max_scenes: int = 5) -> List[dict]:
        """
        Converts article text into scene-wise summaries with image prompts.
        Returns list of: {text, image_prompt}
        """
        if self.use_openai:
            return self._openai_scenes(article_text, max_scenes)
        return self._fallback_scenes(article_text, max_scenes)

    def _openai_scenes(self, text: str, max_scenes: int) -> List[dict]:
        """Use OpenAI to generate structured scenes."""
        try:
            import openai
            client = openai.OpenAI(api_key=self.api_key)
            prompt = f"""Convert this news article into exactly {max_scenes} video scenes.
For each scene return JSON with keys: "text" (1 sentence narration) and "image_prompt" (detailed visual description for image generation).
Return ONLY a JSON array, no markdown.

Article:
{text[:3000]}"""
            response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=1000,
            )
            import json
            scenes = json.loads(response.choices[0].message.content)
            return scenes[:max_scenes]
        except Exception as e:
            logger.warning(f"OpenAI failed: {e}. Using fallback.")
            return self._fallback_scenes(text, max_scenes)

    def _fallback_scenes(self, text: str, max_scenes: int) -> List[dict]:
        """
        Simple extractive approach: split into sentences, pick key ones.
        Works without any API key.
        """
        # Clean text
        text = re.sub(r'\s+', ' ', text).strip()
        sentences = re.split(r'(?<=[.!?])\s+', text)
        sentences = [s.strip() for s in sentences if len(s.strip()) > 30]

        # Pick evenly spaced sentences
        if len(sentences) <= max_scenes:
            selected = sentences[:max_scenes]
        else:
            step = len(sentences) // max_scenes
            selected = [sentences[i * step] for i in range(max_scenes)]

        scenes = []
        visual_styles = [
            "photorealistic news studio background, professional lighting",
            "aerial city view, modern urban landscape, golden hour",
            "close-up documentary style, dramatic lighting, cinematic",
            "government building exterior, official setting, blue sky",
            "people in community, candid documentary photography",
        ]

        for i, sentence in enumerate(selected):
            # Generate a basic image prompt from the sentence keywords
            keywords = self._extract_keywords(sentence)
            style = visual_styles[i % len(visual_styles)]
            image_prompt = f"{keywords}, {style}, 4K professional photography"
            scenes.append({"text": sentence, "image_prompt": image_prompt})

        return scenes

    def _extract_keywords(self, sentence: str) -> str:
        """Extract key nouns/topics from a sentence."""
        stopwords = {"the", "a", "an", "is", "are", "was", "were", "has", "have",
                     "been", "be", "in", "on", "at", "to", "for", "of", "and",
                     "or", "but", "with", "by", "from", "that", "this", "it"}
        words = re.findall(r'\b[A-Za-z]{4,}\b', sentence)
        keywords = [w for w in words if w.lower() not in stopwords][:5]
        return " ".join(keywords) if keywords else sentence[:50]
