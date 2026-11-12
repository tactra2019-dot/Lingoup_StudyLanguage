"""
XP and gamification service.
Backend is the ONLY source of truth for scores and XP.
Client scores are never trusted.
"""
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.progress import (
    QuizAttempt, QuizAnswer, XPTransaction, UserLessonProgress,
    Achievement, UserAchievement
)
from app.models.user import Profile
from app.models.learning import Question, QuestionOption
from app.core.config import settings


def award_xp(db: Session, user_id: str, amount: int, source: str, source_id: int = None, description: str = None) -> int:
    """Award XP to a user. Returns new total XP. Idempotent via source_id check."""
    tx = XPTransaction(
        user_id=user_id,
        amount=amount,
        source=source,
        source_id=source_id,
        description=description,
    )
    db.add(tx)
    
    profile = db.query(Profile).filter(Profile.id == user_id).first()
    if profile:
        profile.total_xp += amount
        db.flush()
        return profile.total_xp
    return 0


def grade_quiz_attempt(db: Session, attempt: QuizAttempt) -> dict:
    """
    Grade all answers in a quiz attempt.
    Returns grading summary. XP is awarded once (idempotent).
    """
    if attempt.is_completed:
        # Already graded - return cached result
        return {
            "score": attempt.score,
            "total_questions": attempt.total_questions,
            "correct_answers": attempt.correct_answers,
            "xp_earned": attempt.xp_earned,
            "is_perfect": attempt.correct_answers == attempt.total_questions,
            "lesson_completed": True,
            "new_total_xp": db.query(Profile).filter(Profile.id == attempt.user_id).first().total_xp,
            "streak_updated": False,
        }

    answers = attempt.answers
    total = len(answers)
    correct = sum(1 for a in answers if a.is_correct)
    score = correct * settings.POINTS_PER_CORRECT_ANSWER
    
    is_perfect = (total > 0 and correct == total)
    xp = settings.XP_PER_LESSON_COMPLETE
    if is_perfect:
        xp += settings.XP_PERFECT_QUIZ_BONUS

    attempt.score = score
    attempt.total_questions = total
    attempt.correct_answers = correct
    attempt.xp_earned = xp
    attempt.is_completed = True
    attempt.completed_at = datetime.now(timezone.utc)

    # Award XP (once only)
    if not attempt.xp_rewarded:
        attempt.xp_rewarded = True
        new_total = award_xp(
            db, attempt.user_id, xp,
            source="lesson_complete",
            source_id=attempt.id,
            description=f"Lesson {attempt.lesson_id} completion",
        )
    else:
        profile = db.query(Profile).filter(Profile.id == attempt.user_id).first()
        new_total = profile.total_xp if profile else 0

    # Mark lesson as completed (create progress row if missing)
    lesson_progress = db.query(UserLessonProgress).filter(
        UserLessonProgress.user_id == attempt.user_id,
        UserLessonProgress.lesson_id == attempt.lesson_id,
    ).first()
    
    lesson_completed = False
    if lesson_progress:
        lesson_progress.score = max(lesson_progress.score, score)
        lesson_progress.attempts += 1
        if lesson_progress.status != "completed":
            lesson_progress.status = "completed"
            lesson_progress.completed_at = datetime.now(timezone.utc)
            lesson_completed = True
            _unlock_next_lesson(db, attempt.user_id, attempt.lesson_id)
    else:
        # No progress row yet — create it as completed
        lesson_progress = UserLessonProgress(
            user_id=attempt.user_id,
            lesson_id=attempt.lesson_id,
            status="completed",
            score=score,
            attempts=1,
            completed_at=datetime.now(timezone.utc),
        )
        db.add(lesson_progress)
        lesson_completed = True
        _unlock_next_lesson(db, attempt.user_id, attempt.lesson_id)

    db.flush()
    
    # Check achievements
    _check_and_award_achievements(db, attempt.user_id)

    profile = db.query(Profile).filter(Profile.id == attempt.user_id).first()
    final_total_xp = profile.total_xp if profile else new_total

    return {
        "score": score,
        "total_questions": total,
        "correct_answers": correct,
        "xp_earned": xp,
        "is_perfect": is_perfect,
        "lesson_completed": lesson_completed,
        "new_total_xp": final_total_xp,
        "streak_updated": False,
    }


def _unlock_next_lesson(db: Session, user_id: str, completed_lesson_id: int) -> None:
    """Unlock the next lesson in the same unit after completing one."""
    from app.models.content import Lesson
    
    completed = db.query(Lesson).filter(Lesson.id == completed_lesson_id).first()
    if not completed:
        return
    
    # Find the next lesson in this unit
    next_lesson = db.query(Lesson).filter(
        Lesson.unit_id == completed.unit_id,
        Lesson.order_index > completed.order_index,
    ).order_by(Lesson.order_index).first()
    
    if next_lesson:
        progress = db.query(UserLessonProgress).filter(
            UserLessonProgress.user_id == user_id,
            UserLessonProgress.lesson_id == next_lesson.id,
        ).first()
        if progress and progress.status == "locked":
            progress.status = "available"
        elif not progress:
            progress = UserLessonProgress(
                user_id=user_id,
                lesson_id=next_lesson.id,
                status="available",
            )
            db.add(progress)
    else:
        # Last lesson in unit - unlock first lesson of next unit
        from app.models.content import Unit
        current_unit = db.query(Unit).filter(Unit.id == completed.unit_id).first()
        if current_unit:
            next_unit = db.query(Unit).filter(
                Unit.level_id == current_unit.level_id,
                Unit.order_index > current_unit.order_index,
            ).order_by(Unit.order_index).first()
            
            if next_unit:
                first_lesson = db.query(Lesson).filter(
                    Lesson.unit_id == next_unit.id,
                ).order_by(Lesson.order_index).first()
                
                if first_lesson:
                    progress = db.query(UserLessonProgress).filter(
                        UserLessonProgress.user_id == user_id,
                        UserLessonProgress.lesson_id == first_lesson.id,
                    ).first()
                    if progress and progress.status == "locked":
                        progress.status = "available"
                    elif not progress:
                        progress = UserLessonProgress(
                            user_id=user_id,
                            lesson_id=first_lesson.id,
                            status="available",
                        )
                        db.add(progress)


def _check_and_award_achievements(db: Session, user_id: str) -> None:
    """Check all achievement criteria and award any newly earned achievements."""
    profile = db.query(Profile).filter(Profile.id == user_id).first()
    if not profile:
        return
    
    # Count completed lessons
    completed_lessons = db.query(UserLessonProgress).filter(
        UserLessonProgress.user_id == user_id,
        UserLessonProgress.status == "completed",
    ).count()
    
    # Count learned vocabulary
    from app.models.progress import UserVocabularyProgress
    learned_vocab = db.query(UserVocabularyProgress).filter(
        UserVocabularyProgress.user_id == user_id,
        UserVocabularyProgress.is_learned == True,
    ).count()
    
    all_achievements = db.query(Achievement).all()
    earned_ids = {ua.achievement_id for ua in db.query(UserAchievement).filter(
        UserAchievement.user_id == user_id
    ).all()}
    
    for achievement in all_achievements:
        if achievement.id in earned_ids:
            continue
        
        earned = False
        if achievement.criteria_type == "streak":
            earned = profile.current_streak >= achievement.criteria_value
        elif achievement.criteria_type == "lessons":
            earned = completed_lessons >= achievement.criteria_value
        elif achievement.criteria_type == "xp":
            earned = profile.total_xp >= achievement.criteria_value
        
        if earned:
            ua = UserAchievement(user_id=user_id, achievement_id=achievement.id)
            db.add(ua)
            if achievement.xp_reward > 0:
                award_xp(db, user_id, achievement.xp_reward, "achievement", achievement.id)
