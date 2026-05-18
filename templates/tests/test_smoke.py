"""Smoke test — minimum proof the package is wired and /healthz works."""

from fastapi.testclient import TestClient

from <package_name>.app import app

client = TestClient(app)


def test_healthz_returns_ok() -> None:
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
