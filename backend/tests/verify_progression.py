import sys
import uuid
from fastapi.testclient import TestClient
from app.main import app

def run_tests():
    client = TestClient(app)

    # 1. Register fresh user
    email = f"prog_test_{uuid.uuid4().hex[:6]}@lingoup.com"
    res = client.post("/api/v1/auth/register", json={
        "email": email,
        "password": "Password123!",
        "display_name": "Progress Tester"
    })
    assert res.status_code == 201, f"Register failed: {res.text}"
    token = res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Check Unit 1 initial state: 0/3 completed, Lesson 1 available, Lessons 2 & 3 locked
    units = client.get("/api/v1/content/units", headers=headers).json()
    u1_id = units[0]["id"]
    assert units[0]["completed_lessons"] == 0
    assert units[0]["total_lessons"] == 3
    assert units[0]["status"] == "available"
    assert units[1]["status"] == "locked"

    lessons = client.get(f"/api/v1/content/units/{u1_id}/lessons", headers=headers).json()
    assert len(lessons) == 3
    assert lessons[0]["status"] == "available"
    assert lessons[1]["status"] == "locked"
    assert lessons[2]["status"] == "locked"

    # 3. Complete Lesson 1
    att1 = client.post("/api/v1/learning/quiz-attempts", json={"lesson_id": lessons[0]["id"]}, headers=headers).json()
    c1 = client.post(f"/api/v1/learning/quiz-attempts/{att1['id']}/complete", headers=headers).json()
    assert c1["lesson_completed"] == True
    assert c1["xp_earned"] > 0
    xp_after_l1 = c1["new_total_xp"]

    # Test idempotence (no duplicate XP on repeat completion)
    c1_repeat = client.post(f"/api/v1/learning/quiz-attempts/{att1['id']}/complete", headers=headers).json()
    assert c1_repeat["new_total_xp"] == xp_after_l1

    # 4. Check state after Lesson 1: Unit 1 has 1/3, Lesson 2 is available
    units = client.get("/api/v1/content/units", headers=headers).json()
    assert units[0]["completed_lessons"] == 1
    assert units[0]["status"] == "available"
    assert units[1]["status"] == "locked"

    lessons = client.get(f"/api/v1/content/units/{u1_id}/lessons", headers=headers).json()
    assert lessons[0]["status"] == "completed"
    assert lessons[1]["status"] == "available"
    assert lessons[2]["status"] == "locked"

    # 5. Complete Lesson 2
    att2 = client.post("/api/v1/learning/quiz-attempts", json={"lesson_id": lessons[1]["id"]}, headers=headers).json()
    c2 = client.post(f"/api/v1/learning/quiz-attempts/{att2['id']}/complete", headers=headers).json()
    assert c2["lesson_completed"] == True

    # Check state after Lesson 2: Unit 1 has 2/3, Lesson 3 is available
    units = client.get("/api/v1/content/units", headers=headers).json()
    assert units[0]["completed_lessons"] == 2
    assert units[0]["status"] == "available"

    lessons = client.get(f"/api/v1/content/units/{u1_id}/lessons", headers=headers).json()
    assert lessons[0]["status"] == "completed"
    assert lessons[1]["status"] == "completed"
    assert lessons[2]["status"] == "available"

    # 6. Complete Lesson 3
    att3 = client.post("/api/v1/learning/quiz-attempts", json={"lesson_id": lessons[2]["id"]}, headers=headers).json()
    c3 = client.post(f"/api/v1/learning/quiz-attempts/{att3['id']}/complete", headers=headers).json()
    assert c3["lesson_completed"] == True

    # Check state after Lesson 3: Unit 1 has 3/3, Unit 1 completed, Unit 2 unlocked (available)!
    units = client.get("/api/v1/content/units", headers=headers).json()
    assert units[0]["completed_lessons"] == 3
    assert units[0]["status"] == "completed"
    assert units[1]["status"] == "available", f"Unit 2 should be available, got {units[1]['status']}"

    # Verify first lesson of Unit 2 is unlocked
    u2_id = units[1]["id"]
    u2_lessons = client.get(f"/api/v1/content/units/{u2_id}/lessons", headers=headers).json()
    assert u2_lessons[0]["status"] == "available", f"Unit 2 Lesson 1 should be available, got {u2_lessons[0]['status']}"

    # 7. Check Gamification sync
    overview = client.get("/api/v1/gamification/progress/overview", headers=headers).json()
    assert overview["completed_lessons"] == 3
    assert overview["current_streak"] >= 1
    assert overview["total_xp"] > 0

    streak = client.get("/api/v1/gamification/streak", headers=headers).json()
    assert streak["current_streak"] >= 1

    print("ALL PROGRESSION & SYNC TESTS PASSED SUCCESSFULLY!")

if __name__ == "__main__":
    run_tests()
