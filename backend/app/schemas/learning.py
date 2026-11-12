from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class VocabularyResponse(BaseModel):
    id: int
    lesson_id: int
    word: str
    translation: str
    pronunciation: Optional[str] = None
    example_sentence: Optional[str] = None
    example_translation: Optional[str] = None
    meaning: Optional[str] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None
    part_of_speech: Optional[str] = None
    order_index: int

    model_config = {"from_attributes": True}


class VocabularyWithProgressResponse(VocabularyResponse):
    is_learned: bool = False
    review_count: int = 0


class QuestionOptionResponse(BaseModel):
    id: int
    text: str
    order_index: int
    # NOTE: is_correct is NOT exposed in the question fetch endpoint (security)

    model_config = {"from_attributes": True}


class QuestionResponse(BaseModel):
    id: int
    lesson_id: int
    question_type: str
    prompt: str
    image_url: Optional[str] = None
    difficulty: int
    order_index: int
    options: List[QuestionOptionResponse] = []

    model_config = {"from_attributes": True}


class QuizAttemptCreate(BaseModel):
    lesson_id: int


class QuizAttemptResponse(BaseModel):
    id: int
    lesson_id: int
    score: int
    total_questions: int
    correct_answers: int
    xp_earned: int
    is_completed: bool
    started_at: datetime
    completed_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class SubmitAnswerRequest(BaseModel):
    question_id: int
    selected_option_id: Optional[int] = None
    text_answer: Optional[str] = None


class SubmitAnswerResponse(BaseModel):
    is_correct: bool
    correct_option_id: Optional[int] = None
    explanation: Optional[str] = None
    points_earned: int


class CompleteQuizResponse(BaseModel):
    score: int
    total_questions: int
    correct_answers: int
    xp_earned: int
    is_perfect: bool
    lesson_completed: bool
    new_total_xp: int
    streak_updated: bool


class VocabularyReviewRequest(BaseModel):
    is_learned: bool


class ProgressOverviewResponse(BaseModel):
    total_xp: int
    current_streak: int
    longest_streak: int
    completed_lessons: int
    total_lessons: int
    learned_vocabulary: int
    total_vocabulary: int
    level_progress_percent: float


class XPResponse(BaseModel):
    total_xp: int
    transactions: List[dict] = []


class StreakResponse(BaseModel):
    current_streak: int
    longest_streak: int
    last_activity_date: Optional[str] = None
    calendar_days: List[str] = []  # List of active YYYY-MM-DD strings


class AchievementResponse(BaseModel):
    id: int
    code: str
    title: str
    description: Optional[str] = None
    icon_emoji: str
    xp_reward: int
    earned: bool = False
    earned_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
