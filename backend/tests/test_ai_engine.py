"""Tests for the AI engine service."""

from datetime import datetime, timedelta, timezone

from app.services.ai_engine import (
    calculate_completion_rate,
    calculate_streak,
    generate_suggestion,
)


class _FakeCompletion:
    def __init__(self, completed_at):
        self.completed_at = completed_at


def test_streak_empty():
    assert calculate_streak([], "daily") == 0


def test_streak_consecutive_days():
    today = datetime.now(timezone.utc)
    completions = [
        _FakeCompletion(today),
        _FakeCompletion(today - timedelta(days=1)),
        _FakeCompletion(today - timedelta(days=2)),
    ]
    assert calculate_streak(completions, "daily") == 3


def test_streak_gap():
    today = datetime.now(timezone.utc)
    completions = [
        _FakeCompletion(today),
        _FakeCompletion(today - timedelta(days=3)),
    ]
    assert calculate_streak(completions, "daily") == 1


def test_completion_rate():
    today = datetime.now(timezone.utc)
    completions = [_FakeCompletion(today - timedelta(days=i)) for i in range(10)]
    rate = calculate_completion_rate(completions, days=30)
    assert 0.3 <= rate <= 0.4  # 10/30


def test_completion_rate_zero_days():
    assert calculate_completion_rate([], days=0) == 0.0


def test_generate_suggestion_known_category():
    s = generate_suggestion("fitness", "low")
    assert len(s) > 0


def test_generate_suggestion_unknown_category():
    s = generate_suggestion("unknown_cat", "medium")
    assert len(s) > 0  # falls back to general
