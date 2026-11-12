from fastapi import APIRouter
from app.api.v1 import auth, content, learning, gamification

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(auth.router)
api_router.include_router(content.router)
api_router.include_router(learning.router)
api_router.include_router(gamification.router)
