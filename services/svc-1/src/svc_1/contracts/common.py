# app/contracts/common.py
from pydantic import BaseModel, Field


class AppError(BaseModel):
    code: str = Field(..., examples=["VALIDATION_ERROR", "NOT_FOUND", "INTERNAL"])
    message: str
