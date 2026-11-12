from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class LanguageResponse(BaseModel):
    id: int
    code: str
    name: str
    native_name: str
    flag_emoji: str
    is_active: bool

    model_config = {"from_attributes": True}


class LevelResponse(BaseModel):
    id: int
    language_id: int
    code: str
    name: str
    description: Optional[str] = None
    order_index: int

    model_config = {"from_attributes": True}


class UnitResponse(BaseModel):
    id: int
    level_id: int
    title: str
    description: Optional[str] = None
    order_index: int
    emoji: Optional[str] = None

    model_config = {"from_attributes": True}


class UnitWithStatusResponse(UnitResponse):
    status: str = "locked"       # locked, available, completed
    completed_lessons: int = 0
    total_lessons: int = 0
    progress_percent: float = 0.0


class LessonResponse(BaseModel):
    id: int
    unit_id: int
    title: str
    description: Optional[str] = None
    objectives: Optional[str] = None
    order_index: int
    xp_reward: int
    lesson_type: str

    model_config = {"from_attributes": True}


class LessonWithStatusResponse(LessonResponse):
    status: str = "locked"   # locked, available, in_progress, completed
    score: int = 0
    attempts: int = 0
