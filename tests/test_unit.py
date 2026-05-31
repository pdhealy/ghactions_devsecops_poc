from __future__ import annotations

from src.main import app


def test_root_endpoint() -> None:
    client = app.test_client()
    response = client.get("/")

    assert response.status_code == 200
    assert response.get_json() == {
        "status": "success",
        "message": "Hello from Google Cloud Run!",
    }


def test_health_endpoint() -> None:
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}
