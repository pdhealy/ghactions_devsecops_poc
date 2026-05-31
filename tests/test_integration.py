from __future__ import annotations

from src import main


def test_get_port_defaults_to_8080(monkeypatch) -> None:
    monkeypatch.delenv("PORT", raising=False)

    assert main.get_port() == 8080


def test_get_port_uses_env_value(monkeypatch) -> None:
    monkeypatch.setenv("PORT", "9090")

    assert main.get_port() == 9090
