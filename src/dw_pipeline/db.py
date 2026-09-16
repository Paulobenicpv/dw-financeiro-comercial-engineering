from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from .config import Settings


def source_engine(settings: Settings) -> Engine:
    return create_engine(settings.source_url, pool_pre_ping=True, pool_recycle=1800, future=True)


def dw_engine(settings: Settings) -> Engine:
    return create_engine(settings.dw_url, pool_pre_ping=True, pool_recycle=1800, future=True)
