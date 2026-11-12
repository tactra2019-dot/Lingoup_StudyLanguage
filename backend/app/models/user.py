import uuid
from datetime import datetime, timezone
from sqlalchemy import (
    Column, String, Integer, Boolean, DateTime, ForeignKey,
    Text, Float, UniqueConstraint, Index
)
from sqlalchemy.orm import relationship
from app.core.database import Base


def utcnow():
    return datetime.now(timezone.utc)


class Profile(Base):
    __tablename__ = "profiles"

    id = Column(String, primary_key=True)  # Supabase auth user ID
    email = Column(String, unique=True, nullable=False)
    display_name = Column(String, nullable=False, default="Learner")
    avatar_url = Column(String, nullable=True)
    hashed_password = Column(String, nullable=True)
    total_xp = Column(Integer, default=0, nullable=False)
    current_streak = Column(Integer, default=0, nullable=False)
    longest_streak = Column(Integer, default=0, nullable=False)
    last_activity_date = Column(String, nullable=True)  # ISO date string YYYY-MM-DD
    selected_language_id = Column(Integer, ForeignKey("languages.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=utcnow, onupdate=utcnow, nullable=False)

    # Relationships
    selected_language = relationship("Language", foreign_keys=[selected_language_id])
    enrollments = relationship("UserEnrollment", back_populates="user", cascade="all, delete-orphan")
    lesson_progress = relationship("UserLessonProgress", back_populates="user", cascade="all, delete-orphan")
    vocab_progress = relationship("UserVocabularyProgress", back_populates="user", cascade="all, delete-orphan")
    quiz_attempts = relationship("QuizAttempt", back_populates="user", cascade="all, delete-orphan")
    xp_transactions = relationship("XPTransaction", back_populates="user", cascade="all, delete-orphan")
    daily_activities = relationship("DailyLearningActivity", back_populates="user", cascade="all, delete-orphan")
    achievements = relationship("UserAchievement", back_populates="user", cascade="all, delete-orphan")
