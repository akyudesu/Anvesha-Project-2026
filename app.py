"""Vercel entrypoint for the FastAPI backend.

Vercel looks for a module-level FastAPI instance named `app` in recognized
entrypoint files. Keep the actual backend implementation in backend/api/server.py
and re-export it here so local imports and tests keep working.
"""

from backend.api.server import app
