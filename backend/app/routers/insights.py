"""AI-powered insights and dashboard routes."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..dependencies import get_current_user
from ..models import User
from ..schemas import DashboardResponse
from ..services.ai_engine import get_dashboard_stats

router = APIRouter(prefix="/insights", tags=["AI Insights"])


@router.get("/dashboard", response_model=DashboardResponse)
def get_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Return aggregated dashboard data with AI-generated insights."""
    return get_dashboard_stats(db, current_user.id)
