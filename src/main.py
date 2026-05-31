from __future__ import annotations

import os

from flask import Flask


app = Flask(__name__)


@app.get("/")
def root() -> tuple[dict[str, str], int]:
    return {"status": "success", "message": "Hello from Google Cloud Run!"}, 200


@app.get("/health")
def health() -> tuple[dict[str, str], int]:
    return {"status": "ok"}, 200


def get_port() -> int:
    port_value = os.getenv("PORT", "8080")
    return int(port_value)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=get_port())
