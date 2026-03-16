"""Application configuration loaded from environment variables."""

import os

SECRET_KEY = os.getenv("SECRET_KEY", "habits-ai-agent-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24 hours

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./habits.db")
