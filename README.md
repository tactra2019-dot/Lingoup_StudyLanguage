# LingoUp – Gamified Language Learning Application

## 🎓 University Final Mobile Project
**Project Topic**: "Ứng dụng học ngoại ngữ: bài học theo cấp độ, từ vựng, câu hỏi luyện tập, điểm số và chuỗi ngày học."
**English**: "A foreign language learning application featuring level-based lessons, vocabulary, practice questions, scores, and daily learning streaks."

---

## 📱 Visual Identity & UI Design
LingoUp implements the modern gamified education visual system:
- **Primary Color**: Mint Green (`#21C7A8`) & Dark Emerald (`#159B83`)
- **Accent**: Electric Blue (`#42B9EE`)
- **Success State**: Bright Green (`#2ED887`)
- **Background**: Soft Clean Gray-White (`#F2F8FA`)
- **Top Header**: Compact mint gradient banner showing Country Flag, Level (A1-B2), Flame Daily Streak (`🔥`), and Diamond XP (`💎`).
- **Learning Path Screen**: Dynamic vertical zigzag progression with 3D cylindrical lesson nodes (Green completed checkmark, Blue glowing current node with progress bar, Gray locked cylinder with lock icon) and thematic companion illustrations.
- **Practice Screen**: Rounded option cards, green/red selection feedback, interactive bottom feedback sheet ("Correct! Well done!" / "Not quite! Try again!"), and confetti animations.
- **Bottom Navigation**: Floating rounded card with 4 main tabs (`Path`, `Vocab`, `Practice`, `Profile`).

---

## 🛠️ Technology Stack

### Frontend (Mobile)
- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: Flutter Riverpod 2.x
- **Routing & Deep Linking**: GoRouter 14.x
- **Networking**: Dio 5.x with custom Bearer Token interceptor
- **Storage**: `flutter_secure_storage` for JWT tokens & credentials
- **Pronunciation / Audio**: `flutter_tts` for real-time speech synthesis
- **Celebration Effects**: `confetti`

### Backend (REST API)
- **Framework**: Python FastAPI
- **ORM & Database**: SQLAlchemy 2.x (SQLite for local dev / PostgreSQL / Supabase for production)
- **Validation**: Pydantic v2
- **Testing**: Pytest with 20 automated tests (100% pass rate)
- **Authentication**: JWT Bearer authentication with bcrypt password hashing

---

## 🚀 How to Run the Project

### 1. Backend Server Setup

```powershell
# Navigate to backend directory
cd D:\FINAL_MOBILE\backend

# Install dependencies (if not already installed)
python -m pip install -r requirements.txt

# Seed the database (creates 1 language, 4 levels, 8 units, 24 lessons, 120+ vocabulary items, 120 practice questions, 10 achievements)
python seed.py

# Start the FastAPI server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at:
- **Base URL**: `http://localhost:8000` (or `http://10.0.2.2:8000` from Android Emulator)
- **Interactive Swagger Docs**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

### 2. Run Backend Tests

```powershell
cd D:\FINAL_MOBILE\backend
python -m pytest
```
*Result: 20 passed tests covering auth, content, learning security, quiz grading, and streak calculations.*

---

### 3. Flutter Application Setup

```powershell
# Navigate to mobile directory
cd D:\FINAL_MOBILE\mobile

# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Run application on Android Emulator or connected device
flutter run
```

### 4. Build Android APK

```powershell
cd D:\FINAL_MOBILE\mobile
flutter build apk --debug
```
*The resulting APK will be located at `mobile/build/app/outputs/flutter-apk/app-debug.apk`.*

---

## 👤 Demo User Accounts

You can register any new account or use the pre-configured demo credentials:
- **Email**: `student@lingoup.com`
- **Password**: `Student123!`
- **Display Name**: Student Learner

*(On the Login screen, click "Use Demo Credentials" to auto-fill)*

---

## 📂 Architecture & Directory Structure

```
FINAL_MOBILE/
├── backend/
│   ├── app/
│   │   ├── api/v1/          # Auth, Content, Learning, Gamification REST routes
│   │   ├── core/            # Config, database engine, JWT middleware
│   │   ├── models/          # SQLAlchemy models (User, Content, Learning, Progress)
│   │   ├── schemas/         # Pydantic request/response schemas
│   │   └── services/        # Gamification & Streak calculation services
│   ├── tests/               # 20 automated pytest test cases
│   ├── seed.py              # Realistic seed content generator
│   └── requirements.txt
│
├── mobile/
│   ├── lib/
│   │   ├── app/             # Router & Root App widget
│   │   ├── core/            # Theme, AppColors, DioClient, Constants
│   │   ├── features/
│   │   │   ├── auth/        # Splash, Onboarding, Login, Register, Language Selection
│   │   │   ├── home/        # Shell & Custom Floating Bottom Nav
│   │   │   ├── learning_path/ # Zigzag 3D nodes, CustomPainter, Header
│   │   │   ├── lessons/     # Lesson Intro & Vocab Pronunciation card screen
│   │   │   ├── vocabulary/  # Vocab Library, Detail view, Interactive Flashcards
│   │   │   ├── practice/    # Quiz screen, Feedback Bottom Sheet, Quiz Results
│   │   │   ├── profile/     # User profile, Streak tracker, Settings
│   │   │   └── gamification/# Achievements & Badges screen
│   │   └── shared/models/   # Immutable Dart models
│   ├── test/                # Unit and widget tests
│   └── pubspec.yaml
│
├── IMPLEMENTATION_STATUS.md # Full audit & component checklist
└── README.md
```

---

## 🔒 Security & Scoring Policy
1. **Server-Side Grading**: The mobile client NEVER receives correct answer flags when fetching questions. Answers are securely submitted to `/api/v1/learning/quiz-attempts/{id}/answers` and graded on the server.
2. **Idempotent Rewards**: Repeated quiz submissions cannot inflate scores or double-count XP rewards.
3. **Streak Integrity**: Streaks strictly verify daily calendar boundaries and timezone offsets.
