"""AI-powered habit insights engine.

Provides rule-based analysis of habit completion patterns, streak calculation,
and personalized suggestions.  Designed to be extended with ML models later.
"""

from collections import Counter
from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from ..models import Habit, HabitCompletion


def calculate_streak(completions: list[HabitCompletion], frequency: str) -> int:
    """Return the current consecutive-day streak for a habit."""
    if not completions:
        return 0

    def _to_aware(dt):
        return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)

    sorted_dates = sorted(
        {_to_aware(c.completed_at).date() for c in completions}, reverse=True
    )

    today = datetime.now(timezone.utc).date()
    if not sorted_dates or sorted_dates[0] < today - timedelta(days=1):
        return 0

    streak = 1
    for i in range(1, len(sorted_dates)):
        if sorted_dates[i - 1] - sorted_dates[i] == timedelta(days=1):
            streak += 1
        else:
            break
    return streak


def calculate_completion_rate(completions: list[HabitCompletion], days: int = 30) -> float:
    """Return the completion rate over the last *days* days (0.0 – 1.0)."""
    if days <= 0:
        return 0.0
    cutoff = datetime.now(timezone.utc) - timedelta(days=days)
    recent = [
        c for c in completions
        if (c.completed_at if c.completed_at.tzinfo else c.completed_at.replace(tzinfo=timezone.utc)) >= cutoff
    ]
    return min(len(recent) / days, 1.0)


def _motivation_level(rate: float) -> str:
    if rate >= 0.8:
        return "high"
    if rate >= 0.4:
        return "medium"
    return "low"


_SUGGESTIONS: dict[str, dict[str, str]] = {
    "health": {
        "low": "Start with just 5 minutes of your health habit. Small wins build momentum!",
        "medium": "You're making progress! Try pairing this habit with an existing routine.",
        "high": "Excellent consistency! Consider increasing the challenge slightly.",
    },
    "productivity": {
        "low": "Try the 2-minute rule: if it takes less than 2 minutes, do it now.",
        "medium": "Good momentum! Block specific time slots for this habit.",
        "high": "You're a productivity champion! Share your strategy with your team.",
    },
    "fitness": {
        "low": "Start with a 10-minute walk. Movement begets movement!",
        "medium": "You're building a solid base. Try adding variety to stay engaged.",
        "high": "Impressive dedication! Consider setting a new personal best.",
    },
    "mindfulness": {
        "low": "Begin with 3 deep breaths when you wake up. Simplicity is key.",
        "medium": "Your mindfulness practice is growing. Try a guided session next.",
        "high": "Beautiful consistency! You might enjoy leading a group session.",
    },
    "learning": {
        "low": "Read just one page or watch one short tutorial today.",
        "medium": "Great learning momentum! Try teaching what you learned to someone.",
        "high": "Knowledge is compounding! Consider starting a study group.",
    },
    "general": {
        "low": "Make it easier: reduce friction by preparing the night before.",
        "medium": "Steady progress! Try habit stacking with something you already do.",
        "high": "Outstanding commitment! You're building a powerful routine.",
    },
}


def generate_suggestion(category: str, motivation: str) -> str:
    cat_suggestions = _SUGGESTIONS.get(category, _SUGGESTIONS["general"])
    return cat_suggestions.get(motivation, cat_suggestions["medium"])


def get_habit_insight(habit: Habit) -> dict:
    """Return an insight dictionary for a single habit."""
    completions = habit.completions or []
    streak = calculate_streak(completions, habit.frequency)
    rate = calculate_completion_rate(completions)
    motivation = _motivation_level(rate)
    suggestion = generate_suggestion(habit.category, motivation)

    return {
        "habit_id": habit.id,
        "habit_title": habit.title,
        "streak": streak,
        "completion_rate": round(rate, 2),
        "suggestion": suggestion,
        "motivation_level": motivation,
    }


def get_dashboard_stats(db: Session, user_id: str) -> dict:
    """Build the full dashboard payload for a user."""
    habits = db.query(Habit).filter(Habit.owner_id == user_id).all()
    active_habits = [h for h in habits if h.is_active]

    today_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    today_completions = 0
    for h in active_habits:
        for c in h.completions:
            completed = c.completed_at
            if completed.tzinfo is None:
                completed = completed.replace(tzinfo=timezone.utc)
            if completed >= today_start:
                today_completions += 1

    insights = [get_habit_insight(h) for h in active_habits]

    # Overall streak = longest current streak among active habits
    overall_streak = max((i["streak"] for i in insights), default=0)

    # Top category by habit count
    categories = [h.category for h in active_habits]
    top_category = Counter(categories).most_common(1)[0][0] if categories else "none"

    return {
        "total_habits": len(habits),
        "active_habits": len(active_habits),
        "total_completions_today": today_completions,
        "overall_streak": overall_streak,
        "top_category": top_category,
        "insights": insights,
    }
