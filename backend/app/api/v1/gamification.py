from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import Profile
from app.models.progress import (
    UserLessonProgress, UserVocabularyProgress, XPTransaction,
    Achievement, UserAchievement, DailyLearningActivity
)
from app.models.content import Level, Unit, Lesson
from app.models.learning import Vocabulary
from app.schemas.learning import (
    ProgressOverviewResponse, XPResponse, StreakResponse, AchievementResponse
)
from app.services.streak_service import get_streak_calendar

router = APIRouter(prefix="/gamification", tags=["gamification"])


@router.get("/progress/overview", response_model=ProgressOverviewResponse)
def get_progress_overview(
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Count completed lessons
    completed_lessons = db.query(UserLessonProgress).filter(
        UserLessonProgress.user_id == current_user.id,
        UserLessonProgress.status == "completed",
    ).count()
    
    # Count total accessible lessons (from enrolled language)
    total_lessons = db.query(Lesson).count()
    
    # Count learned vocabulary
    learned_vocab = db.query(UserVocabularyProgress).filter(
        UserVocabularyProgress.user_id == current_user.id,
        UserVocabularyProgress.is_learned == True,
    ).count()
    
    total_vocab = db.query(Vocabulary).count()
    
    level_progress = (completed_lessons / total_lessons * 100) if total_lessons > 0 else 0.0
    
    return ProgressOverviewResponse(
        total_xp=current_user.total_xp,
        current_streak=current_user.current_streak,
        longest_streak=current_user.longest_streak,
        completed_lessons=completed_lessons,
        total_lessons=total_lessons,
        learned_vocabulary=learned_vocab,
        total_vocabulary=total_vocab,
        level_progress_percent=round(level_progress, 1),
    )


@router.get("/xp", response_model=XPResponse)
def get_xp(
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    transactions = db.query(XPTransaction).filter(
        XPTransaction.user_id == current_user.id,
    ).order_by(XPTransaction.created_at.desc()).limit(20).all()
    
    return XPResponse(
        total_xp=current_user.total_xp,
        transactions=[{
            "id": t.id,
            "amount": t.amount,
            "source": t.source,
            "description": t.description,
            "created_at": t.created_at.isoformat(),
        } for t in transactions],
    )


@router.get("/streak", response_model=StreakResponse)
def get_streak(
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    calendar = get_streak_calendar(db, current_user.id, days=60)
    return StreakResponse(
        current_streak=current_user.current_streak,
        longest_streak=current_user.longest_streak,
        last_activity_date=current_user.last_activity_date,
        calendar_days=calendar,
    )


@router.get("/achievements", response_model=List[AchievementResponse])
def get_achievements(
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    all_achievements = db.query(Achievement).all()
    earned_map = {
        ua.achievement_id: ua.earned_at
        for ua in db.query(UserAchievement).filter(
            UserAchievement.user_id == current_user.id
        ).all()
    }
    
    result = []
    for ach in all_achievements:
        result.append(AchievementResponse(
            id=ach.id,
            code=ach.code,
            title=ach.title,
            description=ach.description,
            icon_emoji=ach.icon_emoji,
            xp_reward=ach.xp_reward,
            earned=ach.id in earned_map,
            earned_at=earned_map.get(ach.id),
        ))
    
    return result
