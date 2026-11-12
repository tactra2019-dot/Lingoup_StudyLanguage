from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import Profile
from app.models.content import Language, Level, Unit, Lesson
from app.models.progress import UserLessonProgress, UserEnrollment
from app.schemas.content import (
    LanguageResponse, LevelResponse, UnitResponse,
    UnitWithStatusResponse, LessonResponse, LessonWithStatusResponse
)

router = APIRouter(prefix="/content", tags=["content"])


@router.get("/languages", response_model=List[LanguageResponse])
def get_languages(db: Session = Depends(get_db)):
    return db.query(Language).filter(Language.is_active == True).all()


@router.get("/levels", response_model=List[LevelResponse])
def get_levels(
    language_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    q = db.query(Level)
    if language_id:
        q = q.filter(Level.language_id == language_id)
    return q.order_by(Level.order_index).all()


@router.get("/units", response_model=List[UnitWithStatusResponse])
def get_units(
    level_id: Optional[int] = None,
    language_id: Optional[int] = None,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    q = db.query(Unit)
    if level_id:
        q = q.filter(Unit.level_id == level_id)
    elif language_id:
        level_ids = [l.id for l in db.query(Level).filter(Level.language_id == language_id).all()]
        q = q.filter(Unit.level_id.in_(level_ids))
    
    units = q.order_by(Unit.order_index).all()
    
    result = []
    
    for idx, unit in enumerate(units):
        lessons = unit.lessons
        total = len(lessons)
        lesson_ids = [l.id for l in lessons]
        
        completed_count = db.query(UserLessonProgress).filter(
            UserLessonProgress.user_id == current_user.id,
            UserLessonProgress.lesson_id.in_(lesson_ids),
            UserLessonProgress.status == "completed",
        ).count() if lesson_ids else 0
        
        all_completed = (total > 0 and completed_count == total)
        
        # First unit always available; subsequent units unlock only when previous is fully completed
        if idx == 0:
            status = "completed" if all_completed else "available"
        else:
            prev_unit_status = result[-1].status if result else "locked"
            if prev_unit_status == "completed":
                status = "completed" if all_completed else "available"
            else:
                status = "locked"
        
        progress = completed_count / total if total > 0 else 0.0
        
        result.append(UnitWithStatusResponse(
            id=unit.id,
            level_id=unit.level_id,
            title=unit.title,
            description=unit.description,
            order_index=unit.order_index,
            emoji=unit.emoji,
            status=status,
            completed_lessons=completed_count,
            total_lessons=total,
            progress_percent=round(progress * 100, 1),
        ))
    
    return result


@router.get("/units/{unit_id}", response_model=UnitWithStatusResponse)
def get_unit(
    unit_id: int,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    unit = db.query(Unit).filter(Unit.id == unit_id).first()
    if not unit:
        raise HTTPException(status_code=404, detail="Unit not found")
    
    lessons = unit.lessons
    total = len(lessons)
    lesson_ids = [l.id for l in lessons]
    
    completed_count = db.query(UserLessonProgress).filter(
        UserLessonProgress.user_id == current_user.id,
        UserLessonProgress.lesson_id.in_(lesson_ids),
        UserLessonProgress.status == "completed",
    ).count() if lesson_ids else 0
    
    all_completed = (total > 0 and completed_count == total)
    status = "completed" if all_completed else "available"
    
    return UnitWithStatusResponse(
        id=unit.id,
        level_id=unit.level_id,
        title=unit.title,
        description=unit.description,
        order_index=unit.order_index,
        emoji=unit.emoji,
        status=status,
        completed_lessons=completed_count,
        total_lessons=total,
        progress_percent=round((completed_count / total * 100) if total > 0 else 0, 1),
    )


@router.get("/lessons/{lesson_id}", response_model=LessonWithStatusResponse)
def get_lesson(
    lesson_id: int,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    
    progress = db.query(UserLessonProgress).filter(
        UserLessonProgress.user_id == current_user.id,
        UserLessonProgress.lesson_id == lesson_id,
    ).first()
    
    is_first_lesson = (lesson.order_index == 0 and lesson.unit and lesson.unit.order_index == 0)
    default_status = "available" if is_first_lesson else "locked"
    status = progress.status if progress else default_status

    return LessonWithStatusResponse(
        id=lesson.id,
        unit_id=lesson.unit_id,
        title=lesson.title,
        description=lesson.description,
        objectives=lesson.objectives,
        order_index=lesson.order_index,
        xp_reward=lesson.xp_reward,
        lesson_type=lesson.lesson_type,
        status=status,
        score=progress.score if progress else 0,
        attempts=progress.attempts if progress else 0,
    )


@router.get("/units/{unit_id}/lessons", response_model=List[LessonWithStatusResponse])
def get_unit_lessons(
    unit_id: int,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    lessons = db.query(Lesson).filter(Lesson.unit_id == unit_id).order_by(Lesson.order_index).all()
    
    result = []
    unit = db.query(Unit).filter(Unit.id == unit_id).first()
    is_first_unit = (unit and unit.order_index == 0)

    for lesson in lessons:
        progress = db.query(UserLessonProgress).filter(
            UserLessonProgress.user_id == current_user.id,
            UserLessonProgress.lesson_id == lesson.id,
        ).first()
        
        # Unit 1 Lesson 1 is available by default even before enrollment or explicit row creation
        default_status = "available" if (is_first_unit and lesson.order_index == 0) else "locked"
        status = progress.status if progress else default_status

        result.append(LessonWithStatusResponse(
            id=lesson.id,
            unit_id=lesson.unit_id,
            title=lesson.title,
            description=lesson.description,
            objectives=lesson.objectives,
            order_index=lesson.order_index,
            xp_reward=lesson.xp_reward,
            lesson_type=lesson.lesson_type,
            status=status,
            score=progress.score if progress else 0,
            attempts=progress.attempts if progress else 0,
        ))
    
    return result


@router.post("/enroll")
def enroll(
    language_id: int,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Enroll user in a language and unlock first lesson."""
    language = db.query(Language).filter(Language.id == language_id).first()
    if not language:
        raise HTTPException(status_code=404, detail="Language not found")
    
    # Get first level
    first_level = db.query(Level).filter(
        Level.language_id == language_id
    ).order_by(Level.order_index).first()
    
    if not first_level:
        raise HTTPException(status_code=404, detail="No levels found for language")
    
    # Check/create enrollment
    enrollment = db.query(UserEnrollment).filter(
        UserEnrollment.user_id == current_user.id,
        UserEnrollment.language_id == language_id,
    ).first()
    
    if not enrollment:
        enrollment = UserEnrollment(
            user_id=current_user.id,
            language_id=language_id,
            level_id=first_level.id,
        )
        db.add(enrollment)
    
    # Update selected language
    current_user.selected_language_id = language_id
    
    # Unlock first lesson of first unit
    first_unit = db.query(Unit).filter(
        Unit.level_id == first_level.id
    ).order_by(Unit.order_index).first()
    
    if first_unit:
        first_lesson = db.query(Lesson).filter(
            Lesson.unit_id == first_unit.id
        ).order_by(Lesson.order_index).first()
        
        if first_lesson:
            existing = db.query(UserLessonProgress).filter(
                UserLessonProgress.user_id == current_user.id,
                UserLessonProgress.lesson_id == first_lesson.id,
            ).first()
            if not existing:
                progress = UserLessonProgress(
                    user_id=current_user.id,
                    lesson_id=first_lesson.id,
                    status="available",
                )
                db.add(progress)
    
    db.commit()
    return {"message": "Enrolled successfully", "language_id": language_id}
