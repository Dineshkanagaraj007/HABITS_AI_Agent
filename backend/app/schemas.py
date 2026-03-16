"""Pydantic schemas for request/response validation."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


# ── Auth Schemas ──────────────────────────────────────────────────────────────

class UserCreate(BaseModel):
    email: EmailStr
    username: str = Field(min_length=3, max_length=50)
    password: str = Field(min_length=6, max_length=100)
    full_name: str = ""


class UserResponse(BaseModel):
    id: str
    email: str
    username: str
    full_name: str
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class LoginRequest(BaseModel):
    username: str
    password: str


# ── Habit Schemas ─────────────────────────────────────────────────────────────

class HabitCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    description: str = ""
    category: str = "general"
    frequency: str = "daily"
    target_count: int = Field(default=1, ge=1)


class HabitUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=200)
    description: Optional[str] = None
    category: Optional[str] = None
    frequency: Optional[str] = None
    target_count: Optional[int] = Field(default=None, ge=1)
    is_active: Optional[bool] = None


class HabitResponse(BaseModel):
    id: str
    title: str
    description: str
    category: str
    frequency: str
    target_count: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    owner_id: str
    completion_count: int = 0

    model_config = {"from_attributes": True}


# ── Completion Schemas ────────────────────────────────────────────────────────

class CompletionCreate(BaseModel):
    note: str = ""
    rating: float = Field(default=5.0, ge=1.0, le=10.0)


class CompletionResponse(BaseModel):
    id: str
    habit_id: str
    completed_at: datetime
    note: str
    rating: float

    model_config = {"from_attributes": True}


# ── AI Insight Schemas ────────────────────────────────────────────────────────

class InsightResponse(BaseModel):
    habit_id: str
    habit_title: str
    streak: int
    completion_rate: float
    suggestion: str
    motivation_level: str  # low, medium, high


class DashboardResponse(BaseModel):
    total_habits: int
    active_habits: int
    total_completions_today: int
    overall_streak: int
    top_category: str
    insights: list[InsightResponse]
