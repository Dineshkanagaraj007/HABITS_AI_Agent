"""Habit CRUD and completion tracking routes."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..dependencies import get_current_user
from ..models import Habit, HabitCompletion, User
from ..schemas import (
    CompletionCreate,
    CompletionResponse,
    HabitCreate,
    HabitResponse,
    HabitUpdate,
)

router = APIRouter(prefix="/habits", tags=["Habits"])


def _habit_to_response(habit: Habit) -> dict:
    data = {
        "id": habit.id,
        "title": habit.title,
        "description": habit.description,
        "category": habit.category,
        "frequency": habit.frequency,
        "target_count": habit.target_count,
        "is_active": habit.is_active,
        "created_at": habit.created_at,
        "updated_at": habit.updated_at,
        "owner_id": habit.owner_id,
        "completion_count": len(habit.completions) if habit.completions else 0,
    }
    return data


@router.get("/", response_model=list[HabitResponse])
def list_habits(
    active_only: bool = False,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(Habit).filter(Habit.owner_id == current_user.id)
    if active_only:
        query = query.filter(Habit.is_active.is_(True))
    habits = query.order_by(Habit.created_at.desc()).all()
    return [_habit_to_response(h) for h in habits]


@router.post("/", response_model=HabitResponse, status_code=status.HTTP_201_CREATED)
def create_habit(
    habit_in: HabitCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = Habit(**habit_in.model_dump(), owner_id=current_user.id)
    db.add(habit)
    db.commit()
    db.refresh(habit)
    return _habit_to_response(habit)


@router.get("/{habit_id}", response_model=HabitResponse)
def get_habit(
    habit_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = db.query(Habit).filter(Habit.id == habit_id, Habit.owner_id == current_user.id).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    return _habit_to_response(habit)


@router.patch("/{habit_id}", response_model=HabitResponse)
def update_habit(
    habit_id: str,
    habit_in: HabitUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = db.query(Habit).filter(Habit.id == habit_id, Habit.owner_id == current_user.id).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")

    update_data = habit_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(habit, field, value)

    db.commit()
    db.refresh(habit)
    return _habit_to_response(habit)


@router.delete("/{habit_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_habit(
    habit_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = db.query(Habit).filter(Habit.id == habit_id, Habit.owner_id == current_user.id).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    db.delete(habit)
    db.commit()


# ── Completions ───────────────────────────────────────────────────────────────

@router.post("/{habit_id}/complete", response_model=CompletionResponse, status_code=status.HTTP_201_CREATED)
def complete_habit(
    habit_id: str,
    completion_in: CompletionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = db.query(Habit).filter(Habit.id == habit_id, Habit.owner_id == current_user.id).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")

    completion = HabitCompletion(
        habit_id=habit_id,
        note=completion_in.note,
        rating=completion_in.rating,
    )
    db.add(completion)
    db.commit()
    db.refresh(completion)
    return completion


@router.get("/{habit_id}/completions", response_model=list[CompletionResponse])
def list_completions(
    habit_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = db.query(Habit).filter(Habit.id == habit_id, Habit.owner_id == current_user.id).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    return habit.completions
