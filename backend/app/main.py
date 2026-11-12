from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.database import engine, Base
from app.api.v1 import api_router

# Create all tables (for local dev - in prod use Alembic migrations)
import app.models  # noqa: ensure all models are imported
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="LingoUp API",
    description="Gamified Language Learning Backend",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS
origins = settings.CORS_ORIGINS.split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins + ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": f"Internal server error: {str(exc)}"},
    )


app.include_router(api_router)


@app.get("/health")
def health_check():
    return {"status": "ok", "app": "LingoUp API", "version": "1.0.0"}


@app.get("/")
def root():
    return {"message": "LingoUp API - Visit /docs for Swagger UI"}
