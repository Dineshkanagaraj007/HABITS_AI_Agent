# HABITS AI Agent

An enterprise habit-tracking platform with AI-powered insights. Built with a **Python / FastAPI** backend and a **Flutter** cross-platform mobile app (Android & iOS).

---

## Architecture

```
├── backend/            Python FastAPI REST API
│   ├── app/
│   │   ├── main.py             Application entry point
│   │   ├── models.py           SQLAlchemy ORM models
│   │   ├── schemas.py          Pydantic request/response schemas
│   │   ├── auth.py             JWT authentication utilities
│   │   ├── config.py           Environment configuration
│   │   ├── database.py         Database engine and session
│   │   ├── dependencies.py     Shared FastAPI dependencies
│   │   ├── routers/
│   │   │   ├── auth.py         Authentication endpoints
│   │   │   ├── habits.py       Habit CRUD & completion endpoints
│   │   │   └── insights.py     AI insights & dashboard endpoint
│   │   └── services/
│   │       └── ai_engine.py    AI-powered habit analysis engine
│   └── tests/                  Pytest test suite (26 tests)
│
└── flutter_app/        Flutter cross-platform mobile app
    ├── lib/
    │   ├── main.dart           App entry point with Material 3 theme
    │   ├── models/             Data models (User, Habit, Dashboard)
    │   ├── services/           API service (HTTP client)
    │   ├── providers/          State management (Provider)
    │   └── screens/            UI screens
    │       ├── splash_screen.dart
    │       ├── login_screen.dart
    │       ├── register_screen.dart
    │       ├── home_screen.dart
    │       ├── dashboard_screen.dart
    │       ├── habits_list_screen.dart
    │       └── add_habit_screen.dart
    └── test/                   Widget tests
```

## Features

### Backend (Python / FastAPI)
- **User authentication** – Register, login, and JWT-based session management
- **Habits CRUD** – Create, read, update, and delete habits with categories and frequencies
- **Completion tracking** – Log daily habit completions with notes and self-ratings
- **AI Insights Engine** – Streak calculation, completion rate analysis, personalized motivational suggestions per category
- **Dashboard API** – Aggregated stats, top category, and per-habit AI insights
- **SQLite database** – Zero-config persistent storage (swap to PostgreSQL for production)
- **Interactive API docs** – Swagger UI at `/docs`

### Flutter App (Android & iOS)
- **Material 3 design** with light/dark theme support
- **Splash → Login/Register** authentication flow with token persistence
- **Dashboard** – Active habits, today's completions, streak counter, top category, and AI insight cards
- **Habits list** – Category emoji icons, completion count, tap-to-complete with rating slider
- **Add habit** – Category chips, frequency selector, clean form UX
- **Pull-to-refresh** on all data screens
- **Provider** state management

## Quick Start

### 1. Backend

```bash
cd backend
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API is now live at `http://localhost:8000`. Open `http://localhost:8000/docs` for interactive API documentation.

### 2. Flutter App

```bash
cd flutter_app
flutter pub get
flutter run           # Runs on connected device / emulator
```

> **Note:** Update the `baseUrl` in `lib/services/api_service.dart` to point to your backend:
> - Android emulator → `http://10.0.2.2:8000/api/v1`
> - iOS simulator → `http://localhost:8000/api/v1`
> - Physical device → `http://<your-ip>:8000/api/v1`

### 3. Run Backend Tests

```bash
cd backend
python3 -m pytest tests/ -v
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/register` | Create a new account |
| POST | `/api/v1/auth/login` | Sign in and receive JWT |
| GET | `/api/v1/auth/me` | Get current user profile |
| GET | `/api/v1/habits/` | List all habits |
| POST | `/api/v1/habits/` | Create a habit |
| GET | `/api/v1/habits/{id}` | Get a specific habit |
| PATCH | `/api/v1/habits/{id}` | Update a habit |
| DELETE | `/api/v1/habits/{id}` | Delete a habit |
| POST | `/api/v1/habits/{id}/complete` | Log a completion |
| GET | `/api/v1/habits/{id}/completions` | List completions |
| GET | `/api/v1/insights/dashboard` | AI-powered dashboard |

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Python 3.12, FastAPI, SQLAlchemy, Pydantic |
| Auth | JWT (python-jose), bcrypt |
| Database | SQLite (dev), PostgreSQL-ready |
| Frontend | Flutter 3, Dart, Provider, Material 3 |
| Testing | pytest, flutter_test |

## License

MIT