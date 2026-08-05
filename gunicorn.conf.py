import multiprocessing
import os

bind = f"{os.getenv('HOST', '0.0.0.0')}:{os.getenv('PORT', '8080')}"
workers = int(os.getenv("GUNICORN_WORKERS", multiprocessing.cpu_count() * 2 + 1))
threads = int(os.getenv("GUNICORN_THREADS", "4"))
worker_class = "gthread"
timeout = int(os.getenv("GUNICORN_TIMEOUT", "30"))
graceful_timeout = int(os.getenv("GUNICORN_GRACEFUL_TIMEOUT", "30"))
accesslog = "-"
errorlog = "-"
