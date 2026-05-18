"""<PROJECT_NAME> FastAPI application."""

from fastapi import FastAPI

app = FastAPI(title="<PROJECT_NAME>")


@app.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "ok"}
