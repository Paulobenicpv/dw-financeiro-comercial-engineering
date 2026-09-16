FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src

COPY requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

COPY config ./config
COPY orchestration ./orchestration
COPY scripts ./scripts
COPY sql ./sql
COPY src ./src

CMD ["python", "orchestration/prefect_flow.py"]
