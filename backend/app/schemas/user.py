from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional
from datetime import datetime


class ProfileBase(BaseModel):
    display_name: str
    avatar_url: Optional[str] = None


class ProfileUpdate(BaseModel):
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None
    selected_language_id: Optional[int] = None


class ProfileResponse(BaseModel):
    id: str
    email: str
    display_name: str
    avatar_url: Optional[str] = None
    total_xp: int
    current_streak: int
    longest_streak: int
    last_activity_date: Optional[str] = None
    selected_language_id: Optional[int] = None
    created_at: datetime

    model_config = {"from_attributes": True}


# Auth schemas (for local dev mode)
class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    display_name: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: ProfileResponse
