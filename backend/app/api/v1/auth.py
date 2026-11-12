"""
Auth endpoints for local development mode.
In production, authentication is handled by Supabase Auth.
These endpoints provide a JWT-compatible local auth system for testing.
"""
import uuid
from datetime import datetime, timezone, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from jose import jwt
import bcrypt

from app.core.database import get_db
from app.core.config import settings
from app.core.auth import get_current_user
from app.models.user import Profile
from app.schemas.user import (
    RegisterRequest, LoginRequest, TokenResponse,
    ProfileResponse, ProfileUpdate
)

router = APIRouter(prefix="/auth", tags=["auth"])

def hash_password(password: str) -> str:
    pwd_bytes = password.encode('utf-8')[:72]
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        pwd_bytes = plain_password.encode('utf-8')[:72]
        return bcrypt.checkpw(pwd_bytes, hashed_password.encode('utf-8'))
    except Exception:
        return False


def create_token(user_id: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=7)
    payload = {
        "sub": user_id,
        "exp": expire,
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)


@router.post("/register", response_model=TokenResponse, status_code=201)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    # Check email uniqueness
    existing = db.query(Profile).filter(Profile.email == req.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_id = str(uuid.uuid4())
    hashed = hash_password(req.password)

    profile = Profile(
        id=user_id,
        email=req.email,
        display_name=req.display_name,
        hashed_password=hashed,
    )
    db.add(profile)
    db.commit()
    db.refresh(profile)

    token = create_token(user_id)
    return TokenResponse(access_token=token, user=ProfileResponse.model_validate(profile))


@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    profile = db.query(Profile).filter(Profile.email == req.email).first()
    if not profile:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    hashed = profile.hashed_password or _get_password(profile.id)
    if not hashed or not verify_password(req.password, hashed):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_token(profile.id)
    return TokenResponse(access_token=token, user=ProfileResponse.model_validate(profile))


@router.get("/me", response_model=ProfileResponse)
def get_me(current_user: Profile = Depends(get_current_user)):
    return ProfileResponse.model_validate(current_user)


@router.patch("/me", response_model=ProfileResponse)
def update_me(
    updates: ProfileUpdate,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if updates.display_name is not None:
        current_user.display_name = updates.display_name
    if updates.avatar_url is not None:
        current_user.avatar_url = updates.avatar_url
    if updates.selected_language_id is not None:
        current_user.selected_language_id = updates.selected_language_id
    db.commit()
    db.refresh(current_user)
    return ProfileResponse.model_validate(current_user)


# In-memory password store for local dev (replace with DB column in prod)
_password_store: dict = {}

def _store_password(user_id: str, hashed: str):
    _password_store[user_id] = hashed

def _get_password(user_id: str) -> Optional[str]:
    return _password_store.get(user_id)
