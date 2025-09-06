# app/contracts/hello.py
from pydantic import BaseModel, Field


class HealthOut(BaseModel):
    ok: bool = True


class HelloQuery(BaseModel):
    name: str = Field(default="world", min_length=1, max_length=100)


class HelloOut(BaseModel):
    message: str  # e.g., "hello world"
