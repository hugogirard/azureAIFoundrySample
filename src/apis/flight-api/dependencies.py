
from fastapi import Request, HTTPException
from azure.data.tables.aio import TableClient
from config import Config
from logging import Logger
import logging
import sys

_config = Config()

# Configure logger
_logger = logging.getLogger('flightapi')

if _config.is_development:
    _logger.setLevel(logging.DEBUG)
else:
    _logger.setLevel(logging.INFO)

# StreamHandler for the console
stream_handler = logging.StreamHandler(sys.stdout)
log_formatter = logging.Formatter("%(asctime)s [%(processName)s: %(process)d] [%(threadName)s: %(thread)d] [%(levelname)s] %(name)s: %(message)s")
stream_handler.setFormatter(log_formatter)
_logger.addHandler(stream_handler)

# ####################################
# Dependency methods using dependency 
# injection in the route
######################################
def get_table_client_airport(request:Request) -> TableClient:
    return request.app.state.table_client_airport

def get_table_client_flight(request:Request) -> TableClient:
    return request.app.state.table_client_flight

def get_logger() -> Logger:
    return _logger