from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, Text, Float
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.models.user import utcnow


class Language(Base):
    __tablename__ = "languages"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(10), unique=True, nullable=False)  # e.g. "en"
    name = Column(String(100), nullable=False)              # e.g. "English"
    native_name = Column(String(100), nullable=False)        # e.g. "English"
    flag_emoji = Column(String(10), nullable=False, default="🇺🇸")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    levels = relationship("Level", back_populates="language", cascade="all, delete-orphan")
    enrollments = relationship("UserEnrollment", back_populates="language")


class Level(Base):
    __tablename__ = "levels"

    id = Column(Integer, primary_key=True, autoincrement=True)
    language_id = Column(Integer, ForeignKey("languages.id"), nullable=False)
    code = Column(String(10), nullable=False)       # e.g. "A1"
    name = Column(String(100), nullable=False)       # e.g. "Beginner"
    description = Column(Text, nullable=True)
    order_index = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    language = relationship("Language", back_populates="levels")
    units = relationship("Unit", back_populates="level", cascade="all, delete-orphan", order_by="Unit.order_index")
    enrollments = relationship("UserEnrollment", back_populates="level")


class Unit(Base):
    __tablename__ = "units"

    id = Column(Integer, primary_key=True, autoincrement=True)
    level_id = Column(Integer, ForeignKey("levels.id"), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    order_index = Column(Integer, nullable=False, default=0)
    emoji = Column(String(10), nullable=True, default="📚")
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    level = relationship("Level", back_populates="units")
    lessons = relationship("Lesson", back_populates="unit", cascade="all, delete-orphan", order_by="Lesson.order_index")


class Lesson(Base):
    __tablename__ = "lessons"

    id = Column(Integer, primary_key=True, autoincrement=True)
    unit_id = Column(Integer, ForeignKey("units.id"), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    objectives = Column(Text, nullable=True)
    order_index = Column(Integer, nullable=False, default=0)
    xp_reward = Column(Integer, default=20, nullable=False)
    lesson_type = Column(String(50), default="mixed")  # vocabulary, quiz, mixed
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    unit = relationship("Unit", back_populates="lessons")
    vocabulary = relationship("Vocabulary", back_populates="lesson", cascade="all, delete-orphan")
    questions = relationship("Question", back_populates="lesson", cascade="all, delete-orphan")
    progress = relationship("UserLessonProgress", back_populates="lesson", cascade="all, delete-orphan")
    quiz_attempts = relationship("QuizAttempt", back_populates="lesson", cascade="all, delete-orphan")
