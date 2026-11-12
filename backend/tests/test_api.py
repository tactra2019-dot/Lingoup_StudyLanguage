"""
Backend tests for LingoUp API.
Run: pytest tests/ -v
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.database import Base, get_db
from app.main import app

# Use SQLite in-memory for tests
TEST_DATABASE_URL = "sqlite:///./test_lingoup.db"
test_engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


def override_get_db():
    db = TestSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(scope="session", autouse=True)
def setup_database():
    Base.metadata.create_all(bind=test_engine)
    # Seed minimal test data
    db = TestSessionLocal()
    from app.models import Language, Level, Unit, Lesson, Question, QuestionOption, Achievement
    from app.models.user import utcnow
    
    lang = Language(code="en", name="English", native_name="English", flag_emoji="🇺🇸")
    db.add(lang)
    db.flush()
    
    level = Level(language_id=lang.id, code="A1", name="Beginner", order_index=0)
    db.add(level)
    db.flush()
    
    unit = Unit(level_id=level.id, title="Test Unit", order_index=0, emoji="📚")
    db.add(unit)
    db.flush()
    
    lesson = Lesson(unit_id=unit.id, title="Test Lesson", order_index=0, xp_reward=20)
    db.add(lesson)
    db.flush()
    
    for i in range(5):
        q = Question(lesson_id=lesson.id, question_type="single_choice",
                     prompt=f"Question {i+1}?", order_index=i)
        db.add(q)
        db.flush()
        for j in range(4):
            opt = QuestionOption(question_id=q.id, text=f"Option {j+1}",
                                 is_correct=(j == 0), order_index=j)
            db.add(opt)
    
    db.commit()
    db.close()
    
    yield
    Base.metadata.drop_all(bind=test_engine)


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def auth_headers(client):
    """Register and login a test user, return auth headers."""
    reg_resp = client.post("/api/v1/auth/register", json={
        "email": "test@lingoup.com",
        "password": "TestPass123!",
        "display_name": "Test User",
    })
    if reg_resp.status_code == 400:
        # Already registered
        login_resp = client.post("/api/v1/auth/login", json={
            "email": "test@lingoup.com",
            "password": "TestPass123!",
        })
        token = login_resp.json()["access_token"]
    else:
        token = reg_resp.json()["access_token"]
    
    return {"Authorization": f"Bearer {token}"}


class TestHealth:
    def test_health_check(self, client):
        resp = client.get("/health")
        assert resp.status_code == 200
        assert resp.json()["status"] == "ok"


class TestAuth:
    def test_register_success(self, client):
        resp = client.post("/api/v1/auth/register", json={
            "email": "newuser@test.com",
            "password": "Password123!",
            "display_name": "New User",
        })
        assert resp.status_code == 201
        data = resp.json()
        assert "access_token" in data
        assert data["user"]["email"] == "newuser@test.com"

    def test_register_duplicate_email(self, client):
        client.post("/api/v1/auth/register", json={
            "email": "dup@test.com",
            "password": "Password123!",
            "display_name": "Dup",
        })
        resp = client.post("/api/v1/auth/register", json={
            "email": "dup@test.com",
            "password": "Password123!",
            "display_name": "Dup2",
        })
        assert resp.status_code == 400

    def test_login_success(self, client):
        client.post("/api/v1/auth/register", json={
            "email": "login@test.com",
            "password": "LoginPass1!",
            "display_name": "Login User",
        })
        resp = client.post("/api/v1/auth/login", json={
            "email": "login@test.com",
            "password": "LoginPass1!",
        })
        assert resp.status_code == 200
        assert "access_token" in resp.json()

    def test_login_wrong_password(self, client):
        client.post("/api/v1/auth/register", json={
            "email": "wrongpass@test.com",
            "password": "RightPass1!",
            "display_name": "Wrong",
        })
        resp = client.post("/api/v1/auth/login", json={
            "email": "wrongpass@test.com",
            "password": "WrongPass!",
        })
        assert resp.status_code == 401

    def test_unauthorized_access(self, client):
        resp = client.get("/api/v1/auth/me")
        assert resp.status_code == 401

    def test_get_me_authenticated(self, client, auth_headers):
        resp = client.get("/api/v1/auth/me", headers=auth_headers)
        assert resp.status_code == 200
        assert "id" in resp.json()


class TestContent:
    def test_get_languages(self, client):
        resp = client.get("/api/v1/content/languages")
        assert resp.status_code == 200
        languages = resp.json()
        assert len(languages) > 0
        assert languages[0]["code"] == "en"

    def test_get_levels(self, client):
        resp = client.get("/api/v1/content/levels")
        assert resp.status_code == 200
        assert len(resp.json()) > 0

    def test_get_units_requires_auth(self, client):
        resp = client.get("/api/v1/content/units")
        assert resp.status_code == 401

    def test_get_units_authenticated(self, client, auth_headers):
        resp = client.get("/api/v1/content/units", headers=auth_headers)
        assert resp.status_code == 200


class TestLearning:
    def test_get_vocabulary_requires_auth(self, client):
        resp = client.get("/api/v1/learning/lessons/1/vocabulary")
        assert resp.status_code == 401

    def test_get_questions_does_not_expose_correct_answers(self, client, auth_headers):
        """Security: correct answer flags must NOT be in question response."""
        db = TestSessionLocal()
        lesson = db.query(__import__('app.models.content', fromlist=['Lesson']).Lesson).first()
        db.close()
        
        if lesson:
            resp = client.get(f"/api/v1/learning/lessons/{lesson.id}/questions", headers=auth_headers)
            assert resp.status_code == 200
            for q in resp.json():
                for opt in q.get("options", []):
                    assert "is_correct" not in opt, "Correct answers must NOT be exposed!"

    def test_quiz_attempt_creation(self, client, auth_headers):
        db = TestSessionLocal()
        lesson = db.query(__import__('app.models.content', fromlist=['Lesson']).Lesson).first()
        db.close()
        
        if lesson:
            resp = client.post("/api/v1/learning/quiz-attempts",
                               json={"lesson_id": lesson.id},
                               headers=auth_headers)
            assert resp.status_code == 201
            assert "id" in resp.json()

    def test_submit_answer_graded_server_side(self, client, auth_headers):
        """Verify server correctly grades answers."""
        db = TestSessionLocal()
        lesson = db.query(__import__('app.models.content', fromlist=['Lesson']).Lesson).first()
        db.close()
        
        if not lesson:
            pytest.skip("No lesson in test DB")
        
        # Create attempt
        attempt_resp = client.post("/api/v1/learning/quiz-attempts",
                                   json={"lesson_id": lesson.id},
                                   headers=auth_headers)
        attempt_id = attempt_resp.json()["id"]
        
        # Get questions
        q_resp = client.get(f"/api/v1/learning/lessons/{lesson.id}/questions", headers=auth_headers)
        questions = q_resp.json()
        
        if questions and questions[0]["options"]:
            q = questions[0]
            opt_id = q["options"][0]["id"]
            
            ans_resp = client.post(
                f"/api/v1/learning/quiz-attempts/{attempt_id}/answers",
                json={"question_id": q["id"], "selected_option_id": opt_id},
                headers=auth_headers,
            )
            assert ans_resp.status_code == 200
            result = ans_resp.json()
            assert "is_correct" in result
            assert "points_earned" in result

    def test_complete_quiz_awards_xp(self, client, auth_headers):
        db = TestSessionLocal()
        lesson = db.query(__import__('app.models.content', fromlist=['Lesson']).Lesson).first()
        db.close()
        
        if not lesson:
            pytest.skip("No lesson in test DB")
        
        attempt_resp = client.post("/api/v1/learning/quiz-attempts",
                                   json={"lesson_id": lesson.id},
                                   headers=auth_headers)
        attempt_id = attempt_resp.json()["id"]
        
        complete_resp = client.post(
            f"/api/v1/learning/quiz-attempts/{attempt_id}/complete",
            headers=auth_headers,
        )
        assert complete_resp.status_code == 200
        result = complete_resp.json()
        assert "xp_earned" in result
        assert result["xp_earned"] >= 0

    def test_duplicate_answer_idempotent(self, client, auth_headers):
        """Submitting same answer twice should not duplicate points."""
        db = TestSessionLocal()
        lesson = db.query(__import__('app.models.content', fromlist=['Lesson']).Lesson).first()
        db.close()
        
        if not lesson:
            pytest.skip("No lesson in test DB")
        
        attempt_resp = client.post("/api/v1/learning/quiz-attempts",
                                   json={"lesson_id": lesson.id},
                                   headers=auth_headers)
        attempt_id = attempt_resp.json()["id"]
        
        q_resp = client.get(f"/api/v1/learning/lessons/{lesson.id}/questions", headers=auth_headers)
        questions = q_resp.json()
        
        if questions and questions[0]["options"]:
            q = questions[0]
            opt_id = q["options"][0]["id"]
            
            resp1 = client.post(f"/api/v1/learning/quiz-attempts/{attempt_id}/answers",
                                json={"question_id": q["id"], "selected_option_id": opt_id},
                                headers=auth_headers)
            resp2 = client.post(f"/api/v1/learning/quiz-attempts/{attempt_id}/answers",
                                json={"question_id": q["id"], "selected_option_id": opt_id},
                                headers=auth_headers)
            
            assert resp1.json()["points_earned"] == resp2.json()["points_earned"]


class TestStreak:
    def test_streak_data_structure(self, client, auth_headers):
        resp = client.get("/api/v1/gamification/streak", headers=auth_headers)
        assert resp.status_code == 200
        data = resp.json()
        assert "current_streak" in data
        assert "longest_streak" in data
        assert "calendar_days" in data

    def test_streak_calculation(self):
        """Unit test for streak calculation logic."""
        from datetime import datetime, timedelta
        from app.services.streak_service import _recalculate_streak
        from sqlalchemy import create_engine
        from sqlalchemy.orm import sessionmaker
        
        from app.models.progress import DailyLearningActivity
        from app.models.user import Profile
        
        db = TestSessionLocal()
        # Create a test user
        import uuid
        uid = str(uuid.uuid4())
        profile = Profile(id=uid, email=f"{uid}@streak.test", display_name="Streak Test")
        db.add(profile)
        db.flush()
        
        today = datetime.now().strftime("%Y-%m-%d")
        yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
        two_days_ago = (datetime.now() - timedelta(days=2)).strftime("%Y-%m-%d")
        
        for d in [today, yesterday, two_days_ago]:
            act = DailyLearningActivity(user_id=uid, activity_date=d)
            db.add(act)
        db.flush()
        
        _recalculate_streak(db, uid, today)
        db.flush()
        
        updated = db.query(Profile).filter(Profile.id == uid).first()
        assert updated.current_streak == 3
        
        db.rollback()
        db.close()


class TestOwnership:
    def test_user_cannot_access_other_user_attempt(self, client):
        """Users must only access their own quiz attempts."""
        # Register user 1
        resp1 = client.post("/api/v1/auth/register", json={
            "email": "owner1@test.com", "password": "Pass1234!", "display_name": "Owner1"
        })
        headers1 = {"Authorization": f"Bearer {resp1.json()['access_token']}"}
        
        # Register user 2  
        resp2 = client.post("/api/v1/auth/register", json={
            "email": "owner2@test.com", "password": "Pass1234!", "display_name": "Owner2"
        })
        headers2 = {"Authorization": f"Bearer {resp2.json()['access_token']}"}
        
        db = TestSessionLocal()
        lesson = db.query(__import__('app.models.content', fromlist=['Lesson']).Lesson).first()
        db.close()
        
        if not lesson:
            pytest.skip("No lesson")
        
        # User 1 creates attempt
        attempt_resp = client.post("/api/v1/learning/quiz-attempts",
                                   json={"lesson_id": lesson.id},
                                   headers=headers1)
        attempt_id = attempt_resp.json()["id"]
        
        # User 2 tries to complete user 1's attempt - should fail
        resp = client.post(f"/api/v1/learning/quiz-attempts/{attempt_id}/complete",
                           headers=headers2)
        assert resp.status_code == 404  # Not found (ownership check)
