
from fastapi import Request, HTTPException
from azure.data.tables.aio import TableClient
from logging import Logger
import logging
import sys

# ####################################
# Dependency methods using dependency 
# injection in the route
######################################
def get_table_client_airport(request:Request) -> TableClient:
    return request.app.state.table_client_airport