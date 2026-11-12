from sqlalchemy import (
    Column, String, Integer, Boolean, DateTime, ForeignKey,
    Text, Float, UniqueConstraint, Date
)
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.models.user import utcnow


class UserEnrollment(Base):
    """Tracks which language/level a user is enrolled in."""
    __tablename__ = "user_enrollments"
    __table_args__ = (
        UniqueConstraint("user_id", "language_id", name="uq_enrollment"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("profiles.id"), nullable=False)
    language_id = Column(Integer, ForeignKey("languages.id"), nullable=False)
    level_id = Column(Integer, ForeignKey("levels.id"), nullable=False)
    enrolled_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    user = relationship("Profile", back_populates="enrollments")
    language = relationship("Language", back_populates="enrollments")
    level = relationship("Level", back_populates="enrollments")


class UserLessonProgress(Base):
    """Tracks per-lesson completion status."""
    __tablename__ = "user_lesson_progress"
    __table_args__ = (
        UniqueConstraint("user_id", "lesson_id", name="uq_lesson_progress"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("profiles.id"), nullable=False)
    lesson_id = Column(Integer, ForeignKey("lessons.id"), nullable=False)
    status = Column(String(20), default="locked")  # locked, available, in_progress, completed
    score = Column(Integer, default=0)
    attempts = Column(Integer, default=0)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=utcnow, onupdate=utcnow, nullable=False)

    user = relationship("Profile", back_populates="lesson_progress")
    lesson = relationship("Lesson", back_populates="progress")


class UserVocabularyProgress(Base):
    """Tracks individual vocabulary word learning status."""
    __tablename__ = "user_vocabulary_progress"
    __table_args__ = (
        UniqueConstraint("user_id", "vocabulary_id", name="uq_vocab_progress"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("profiles.id"), nullable=False)
    vocabulary_id = Column(Integer, ForeignKey("vocabulary.id"), nullable=False)
    is_learned = Column(Boolean, default=False, nullable=False)
    review_count = Column(Integer, default=0, nullable=False)
    last_reviewed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    user = relationship("Profile", back_populates="vocab_progress")
    vocabulary = relationship("Vocabulary", back_populates="user_progress")


class QuizAttempt(Base):
    """A single quiz attempt for a lesson."""
    __tablename__ = "quiz_attempts"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("profiles.id"), nullable=False)
    lesson_id = Column(Integer, ForeignKey("lessons.id"), nullable=False)
    score = Column(Integer, default=0)
    total_questions = Column(Integer, default=0)
    correct_answers = Column(Integer, default=0)
    xp_earned = Column(Integer, default=0)
    xp_rewarded = Column(Boolean, default=False)  # prevent double XP
    is_completed = Column(Boolean, default=False)
    started_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)
    completed_at = Column(DateTime(timezone=True), nullable=True)

    user = relationship("Profile", back_populates="quiz_attempts")
    lesson = relationship("Lesson", back_populates="quiz_attempts")
    answers = relationship("QuizAnswer", back_populates="attempt", cascade="all, delete-orphan")


class QuizAnswer(Base):
    """Individual answer within a quiz attempt."""
    __tablename__ = "quiz_answers"

    id = Column(Integer, primary_key=True, autoincrement=True)
    attempt_id = Column(Integer, ForeignKey("quiz_attempts.id"), nullable=False)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False)
    selected_option_id = Column(Integer, ForeignKey("question_options.id"), nullable=True)
    text_answer = Column(Text, nullable=True)  # for fill-in-blank
    is_correct = Column(Boolean, default=False)
    points_earned = Column(Integer, default=0)
    answered_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    attempt = relationship("QuizAttempt", back_populates="answers")
    question = relationship("Question", back_populates="quiz_answers")


class XPTransaction(Base):
    """Immutable XP earning events."""
    __tablename__ = "xp_transactions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("profiles.id"), nullable=False)
    amount = Column(Integer, nullable=False)
    source = Column(String(50), nullable=False)  # lesson_complete, quiz_bonus, etc.
    source_id = Column(Integer, nullable=True)   # e.g. lesson_id or attempt_id
    description = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    user = relationship("Profile", back_populates="xp_transactions")


class DailyLearningActivity(Base):
    """One record per user per calendar day they completed meaningful activity."""
    __tablename__ = "daily_learning_activity"
    __table_args__ = (
        UniqueConstraint("user_id", "activity_date", name="uq_daily_activity"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("profiles.id"), nullable=False)
    activity_date = Column(String(10), nullable=False)  # YYYY-MM-DD
    activities_count = Column(Integer, default=1)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    user = relationship("Profile", back_populates="daily_activities")


class Achievement(Base):
    """Achievement definitions."""
    __tablename__ = "achievements"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(100), unique=True, nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    icon_emoji = Column(String(10), default="🏆")
    xp_reward = Column(Integer, default=0)
    criteria_type = Column(String(50), nullable=False)  # streak, lessons, xp, vocab
    criteria_value = Column(Integer, nullable=False)

    user_achievements = relationship("UserAchievement", back_populates="achievement", cascade="all, delete-orphan")


class UserAchievement(Base):
    """Awards granted to a user."""
    __tablename__ = "user_achievements"
    __table_args__ = (
        UniqueConstraint("user_id", "achievement_id", name="uq_user_achievement"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("profiles.id"), nullable=False)
    achievement_id = Column(Integer, ForeignKey("achievements.id"), nullable=False)
    earned_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    user = relationship("Profile", back_populates="achievements")
    achievement = relationship("Achievement", back_populates="user_achievements")
