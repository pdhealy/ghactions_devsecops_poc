from __future__ import annotations

import os

import structlog
from flask import Flask


app = Flask(__name__)
logger = structlog.get_logger()


@app.errorhandler(Exception)
def handle_exception(e: Exception) -> tuple[dict[str, str], int]:
    logger.error("Unhandled exception", exc_info=e)
    return {"status": "error", "message": "Internal server error"}, 500


@app.get("/")
def root() -> tuple[dict[str, str], int]:
    logger.info("Handling root request")
    return {"status": "success", "message": "Hello from Google Cloud Run!"}, 200


@app.get("/health")
def health() -> tuple[dict[str, str], int]:
    return {"status": "ok"}, 200


def get_port() -> int:
    port_value = os.getenv("PORT", "8080")
    return int(port_value)


def get_host() -> str:
    # Bind to all interfaces for container runtimes.
    return os.getenv("HOST", "0.0.0.0")  # nosec B104


if __name__ == "__main__":
    app.run(host=get_host(), port=get_port())
