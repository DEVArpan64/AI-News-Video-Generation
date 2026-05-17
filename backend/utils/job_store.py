"""
Simple in-memory job store.
For production: replace with Redis or a database.
"""

from typing import Dict, Optional
from models.schemas import JobStatus


class JobStore:
    def __init__(self):
        self._jobs: Dict[str, JobStatus] = {}

    def create(self, job_id: str) -> JobStatus:
        job = JobStatus(job_id=job_id, status="queued", current_step="Queued")
        self._jobs[job_id] = job
        return job

    def get(self, job_id: str) -> Optional[JobStatus]:
        return self._jobs.get(job_id)

    def update(self, job_id: str, **kwargs):
        job = self._jobs.get(job_id)
        if job:
            for k, v in kwargs.items():
                setattr(job, k, v)

    def list_all(self):
        return [{"job_id": j.job_id, "status": j.status, "progress": j.progress}
                for j in self._jobs.values()]


# Singleton
job_store = JobStore()
