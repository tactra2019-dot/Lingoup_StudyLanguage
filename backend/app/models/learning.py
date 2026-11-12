from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.models.user import utcnow


class Vocabulary(Base):
    __tablename__ = "vocabulary"

    id = Column(Integer, primary_key=True, autoincrement=True)
    lesson_id = Column(Integer, ForeignKey("lessons.id"), nullable=False)
    word = Column(String(200), nullable=False)
    translation = Column(String(200), nullable=False)
    pronunciation = Column(String(200), nullable=True)
    example_sentence = Column(Text, nullable=True)
    example_translation = Column(Text, nullable=True)
    meaning = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    audio_url = Column(String(500), nullable=True)
    part_of_speech = Column(String(50), nullable=True)  # noun, verb, adj, etc.
    order_index = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    lesson = relationship("Lesson", back_populates="vocabulary")
    user_progress = relationship("UserVocabularyProgress", back_populates="vocabulary", cascade="all, delete-orphan")


class Question(Base):
    __tablename__ = "questions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    lesson_id = Column(Integer, ForeignKey("lessons.id"), nullable=False)
    question_type = Column(String(50), nullable=False)  # single_choice, fill_blank, matching
    prompt = Column(Text, nullable=False)
    image_url = Column(String(500), nullable=True)
    explanation = Column(Text, nullable=True)
    difficulty = Column(Integer, default=1)  # 1=easy, 2=medium, 3=hard
    order_index = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    lesson = relationship("Lesson", back_populates="questions")
    options = relationship("QuestionOption", back_populates="question", cascade="all, delete-orphan", order_by="QuestionOption.order_index")
    quiz_answers = relationship("QuizAnswer", back_populates="question", cascade="all, delete-orphan")


class QuestionOption(Base):
    __tablename__ = "question_options"

    id = Column(Integer, primary_key=True, autoincrement=True)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False)
    text = Column(Text, nullable=False)
    is_correct = Column(Boolean, default=False, nullable=False)
    order_index = Column(Integer, default=0, nullable=False)

    question = relationship("Question", back_populates="options")
