"""HABITS AI Agent – FastAPI application entry point."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import Base, engine
from .routers import auth, habits, insights

# Create all database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="HABITS AI Agent",
    description="Enterprise habit tracking platform with AI-powered insights",
    version="1.0.0",
)

# CORS – allow Flutter app on any origin during development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router, prefix="/api/v1")
app.include_router(habits.router, prefix="/api/v1")
app.include_router(insights.router, prefix="/api/v1")


@app.get("/")
def root():
    return {
        "name": "HABITS AI Agent",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
    }


@app.get("/health")
def health_check():
    return {"status": "healthy"}
