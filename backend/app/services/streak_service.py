"""
Streak service: calculates and updates daily learning streaks.
Handles timezone-aware date boundaries correctly.
"""
from datetime import datetime, timezone, timedelta
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from app.models.progress import DailyLearningActivity
from app.models.user import Profile


def get_today_date(tz_offset_hours: int = 7) -> str:
    """Return today's date in YYYY-MM-DD format for the given UTC offset."""
    utc_now = datetime.now(timezone.utc)
    local_now = utc_now + timedelta(hours=tz_offset_hours)
    return local_now.strftime("%Y-%m-%d")


def record_daily_activity(db: Session, user_id: str, tz_offset_hours: int = 7) -> bool:
    """
    Record today's learning activity. Returns True if streak was updated.
    Uses INSERT OR IGNORE semantics via IntegrityError catch.
    """
    today = get_today_date(tz_offset_hours)
    
    # Check if already recorded today
    existing = db.query(DailyLearningActivity).filter(
        DailyLearningActivity.user_id == user_id,
        DailyLearningActivity.activity_date == today,
    ).first()
    
    if existing:
        existing.activities_count += 1
        db.commit()
        return False  # Streak already counted today
    
    # New day - create record
    activity = DailyLearningActivity(
        user_id=user_id,
        activity_date=today,
        activities_count=1,
    )
    db.add(activity)
    
    try:
        db.flush()
    except IntegrityError:
        db.rollback()
        return False
    
    # Recalculate streak
    _recalculate_streak(db, user_id, today)
    db.commit()
    return True


def _recalculate_streak(db: Session, user_id: str, today: str) -> None:
    """Recalculate current and longest streak for user."""
    # Get all activity dates sorted descending
    activities = db.query(DailyLearningActivity).filter(
        DailyLearningActivity.user_id == user_id,
    ).order_by(DailyLearningActivity.activity_date.desc()).all()
    
    if not activities:
        return
    
    dates = [a.activity_date for a in activities]
    
    # Calculate current streak (consecutive days ending today)
    current_streak = 0
    expected = today
    for date_str in dates:
        if date_str == expected:
            current_streak += 1
            # Next expected date is the previous day
            d = datetime.strptime(expected, "%Y-%m-%d")
            d -= timedelta(days=1)
            expected = d.strftime("%Y-%m-%d")
        else:
            break
    
    # Calculate longest streak
    longest_streak = 0
    streak = 1
    for i in range(1, len(dates)):
        d1 = datetime.strptime(dates[i - 1], "%Y-%m-%d")
        d2 = datetime.strptime(dates[i], "%Y-%m-%d")
        if (d1 - d2).days == 1:
            streak += 1
            longest_streak = max(longest_streak, streak)
        else:
            streak = 1
    longest_streak = max(longest_streak, streak, current_streak)
    
    # Update profile
    profile = db.query(Profile).filter(Profile.id == user_id).first()
    if profile:
        profile.current_streak = current_streak
        profile.longest_streak = max(profile.longest_streak, longest_streak)
        profile.last_activity_date = today


def get_streak_calendar(db: Session, user_id: str, days: int = 30) -> list[str]:
    """Return list of active date strings for the last N days."""
    activities = db.query(DailyLearningActivity).filter(
        DailyLearningActivity.user_id == user_id,
    ).order_by(DailyLearningActivity.activity_date.desc()).limit(days).all()
    return [a.activity_date for a in activities]
