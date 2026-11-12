from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # Supabase
    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""

    # Database
    DATABASE_URL: str = "sqlite:///./lingoup_dev.db"

    # JWT
    JWT_SECRET: str = "dev-secret-change-in-production"
    JWT_ALGORITHM: str = "HS256"

    # App
    APP_ENV: str = "development"
    APP_HOST: str = "0.0.0.0"
    APP_PORT: int = 8000
    CORS_ORIGINS: str = "http://localhost:3000,http://10.0.2.2:8000"

    # Scoring constants
    POINTS_PER_CORRECT_ANSWER: int = 10
    XP_PER_LESSON_COMPLETE: int = 20
    XP_PERFECT_QUIZ_BONUS: int = 10

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
