from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import Profile
from app.models.learning import Vocabulary, Question, QuestionOption
from app.models.progress import (
    UserVocabularyProgress, QuizAttempt, QuizAnswer, UserLessonProgress
)
from app.schemas.learning import (
    VocabularyWithProgressResponse,
    QuestionResponse, QuestionOptionResponse,
    QuizAttemptCreate, QuizAttemptResponse,
    SubmitAnswerRequest, SubmitAnswerResponse,
    CompleteQuizResponse,
    VocabularyReviewRequest,
)
from app.services.gamification_service import grade_quiz_attempt
from app.services.streak_service import record_daily_activity
from app.core.config import settings

router = APIRouter(prefix="/learning", tags=["learning"])


@router.get("/lessons/{lesson_id}/vocabulary", response_model=List[VocabularyWithProgressResponse])
def get_lesson_vocabulary(
    lesson_id: int,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    vocab_items = db.query(Vocabulary).filter(
        Vocabulary.lesson_id == lesson_id
    ).order_by(Vocabulary.order_index).all()
    
    result = []
    for vocab in vocab_items:
        progress = db.query(UserVocabularyProgress).filter(
            UserVocabularyProgress.user_id == current_user.id,
            UserVocabularyProgress.vocabulary_id == vocab.id,
        ).first()
        
        result.append(VocabularyWithProgressResponse(
            id=vocab.id,
            lesson_id=vocab.lesson_id,
            word=vocab.word,
            translation=vocab.translation,
            pronunciation=vocab.pronunciation,
            example_sentence=vocab.example_sentence,
            example_translation=vocab.example_translation,
            meaning=vocab.meaning,
            image_url=vocab.image_url,
            audio_url=vocab.audio_url,
            part_of_speech=vocab.part_of_speech,
            order_index=vocab.order_index,
            is_learned=progress.is_learned if progress else False,
            review_count=progress.review_count if progress else 0,
        ))
    
    return result


@router.get("/lessons/{lesson_id}/questions", response_model=List[QuestionResponse])
def get_lesson_questions(
    lesson_id: int,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return questions WITHOUT correct answer flags (security: graded server-side)."""
    questions = db.query(Question).filter(
        Question.lesson_id == lesson_id
    ).order_by(Question.order_index).all()
    
    result = []
    for q in questions:
        options = [
            QuestionOptionResponse(
                id=opt.id,
                text=opt.text,
                order_index=opt.order_index,
                # is_correct intentionally excluded
            )
            for opt in q.options
        ]
        result.append(QuestionResponse(
            id=q.id,
            lesson_id=q.lesson_id,
            question_type=q.question_type,
            prompt=q.prompt,
            image_url=q.image_url,
            difficulty=q.difficulty,
            order_index=q.order_index,
            options=options,
        ))
    
    return result


@router.post("/quiz-attempts", response_model=QuizAttemptResponse, status_code=201)
def create_quiz_attempt(
    req: QuizAttemptCreate,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    attempt = QuizAttempt(
        user_id=current_user.id,
        lesson_id=req.lesson_id,
    )
    db.add(attempt)
    db.commit()
    db.refresh(attempt)
    return QuizAttemptResponse.model_validate(attempt)


@router.post("/quiz-attempts/{attempt_id}/answers", response_model=SubmitAnswerResponse)
def submit_answer(
    attempt_id: int,
    req: SubmitAnswerRequest,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    attempt = db.query(QuizAttempt).filter(
        QuizAttempt.id == attempt_id,
        QuizAttempt.user_id == current_user.id,
    ).first()
    if not attempt:
        raise HTTPException(status_code=404, detail="Quiz attempt not found")
    if attempt.is_completed:
        raise HTTPException(status_code=400, detail="Quiz already completed")
    
    # Check question exists
    question = db.query(Question).filter(Question.id == req.question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")
    
    # Prevent duplicate answers
    existing_answer = db.query(QuizAnswer).filter(
        QuizAnswer.attempt_id == attempt_id,
        QuizAnswer.question_id == req.question_id,
    ).first()
    if existing_answer:
        # Return cached result
        correct_opt = db.query(QuestionOption).filter(
            QuestionOption.question_id == req.question_id,
            QuestionOption.is_correct == True,
        ).first()
        return SubmitAnswerResponse(
            is_correct=existing_answer.is_correct,
            correct_option_id=correct_opt.id if correct_opt else None,
            explanation=question.explanation,
            points_earned=existing_answer.points_earned,
        )
    
    # Grade the answer server-side
    is_correct = False
    correct_option = None
    
    if req.selected_option_id:
        option = db.query(QuestionOption).filter(
            QuestionOption.id == req.selected_option_id,
            QuestionOption.question_id == req.question_id,
        ).first()
        if option:
            is_correct = option.is_correct
            correct_option = db.query(QuestionOption).filter(
                QuestionOption.question_id == req.question_id,
                QuestionOption.is_correct == True,
            ).first()
    elif req.text_answer:
        # For fill-in-blank: compare with correct option text
        correct_option = db.query(QuestionOption).filter(
            QuestionOption.question_id == req.question_id,
            QuestionOption.is_correct == True,
        ).first()
        if correct_option:
            is_correct = req.text_answer.strip().lower() == correct_option.text.strip().lower()
    
    points = settings.POINTS_PER_CORRECT_ANSWER if is_correct else 0
    
    answer = QuizAnswer(
        attempt_id=attempt_id,
        question_id=req.question_id,
        selected_option_id=req.selected_option_id,
        text_answer=req.text_answer,
        is_correct=is_correct,
        points_earned=points,
    )
    db.add(answer)
    db.commit()
    
    return SubmitAnswerResponse(
        is_correct=is_correct,
        correct_option_id=correct_option.id if correct_option else None,
        explanation=question.explanation,
        points_earned=points,
    )


@router.post("/quiz-attempts/{attempt_id}/complete", response_model=CompleteQuizResponse)
def complete_quiz(
    attempt_id: int,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    attempt = db.query(QuizAttempt).filter(
        QuizAttempt.id == attempt_id,
        QuizAttempt.user_id == current_user.id,
    ).first()
    if not attempt:
        raise HTTPException(status_code=404, detail="Quiz attempt not found")
    
    result = grade_quiz_attempt(db, attempt)
    
    # Record streak
    streak_updated = record_daily_activity(db, current_user.id)
    result["streak_updated"] = streak_updated
    
    db.commit()
    return CompleteQuizResponse(**result)


@router.get("/quiz-attempts/history", response_model=List[QuizAttemptResponse])
def get_quiz_history(
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    attempts = db.query(QuizAttempt).filter(
        QuizAttempt.user_id == current_user.id,
        QuizAttempt.is_completed == True,
    ).order_by(QuizAttempt.completed_at.desc()).limit(50).all()
    return [QuizAttemptResponse.model_validate(a) for a in attempts]


@router.post("/vocabulary/{word_id}/review")
def review_vocabulary(
    word_id: int,
    req: VocabularyReviewRequest,
    current_user: Profile = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    vocab = db.query(Vocabulary).filter(Vocabulary.id == word_id).first()
    if not vocab:
        raise HTTPException(status_code=404, detail="Vocabulary not found")
    
    progress = db.query(UserVocabularyProgress).filter(
        UserVocabularyProgress.user_id == current_user.id,
        UserVocabularyProgress.vocabulary_id == word_id,
    ).first()
    
    if not progress:
        progress = UserVocabularyProgress(
            user_id=current_user.id,
            vocabulary_id=word_id,
            is_learned=req.is_learned,
            review_count=1,
            last_reviewed_at=datetime.now(timezone.utc),
        )
        db.add(progress)
    else:
        progress.is_learned = req.is_learned
        progress.review_count += 1
        progress.last_reviewed_at = datetime.now(timezone.utc)
    
    db.commit()
    return {"message": "Review recorded", "is_learned": req.is_learned}
