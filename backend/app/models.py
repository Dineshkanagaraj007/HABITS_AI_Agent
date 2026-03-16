"""SQLAlchemy ORM models for the HABITS AI Agent."""

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from .database import Base


def _utcnow():
    return datetime.now(timezone.utc)


def _generate_uuid():
    return str(uuid.uuid4())


class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=_generate_uuid)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, default="")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=_utcnow)

    habits = relationship("Habit", back_populates="owner", cascade="all, delete-orphan")


class Habit(Base):
    __tablename__ = "habits"

    id = Column(String, primary_key=True, default=_generate_uuid)
    title = Column(String, nullable=False)
    description = Column(Text, default="")
    category = Column(String, default="general")  # health, productivity, mindfulness, fitness, learning, general
    frequency = Column(String, default="daily")  # daily, weekly, monthly
    target_count = Column(Integer, default=1)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=_utcnow)
    updated_at = Column(DateTime, default=_utcnow, onupdate=_utcnow)
    owner_id = Column(String, ForeignKey("users.id"), nullable=False)

    owner = relationship("User", back_populates="habits")
    completions = relationship("HabitCompletion", back_populates="habit", cascade="all, delete-orphan")


class HabitCompletion(Base):
    __tablename__ = "habit_completions"

    id = Column(String, primary_key=True, default=_generate_uuid)
    habit_id = Column(String, ForeignKey("habits.id"), nullable=False)
    completed_at = Column(DateTime, default=_utcnow)
    note = Column(Text, default="")
    rating = Column(Float, default=5.0)  # 1-10 self-rating

    habit = relationship("Habit", back_populates="completions")
