from fastapi import APIRouter, Depends, HTTPException
from azure.data.tables.aio import TableClient
from dependencies import get_table_client_flight, get_logger
from logging import Logger
from typing import List, Annotated, Dict, Any
from models import Flight

router = APIRouter(prefix="/flight")


@router.get("/{country}/{airport_code}",description="Return the list of all flight for a specific destination")
async def get_airport(country: str,
                      airport_code: str,
                      logger: Annotated[Logger, Depends(get_logger)],
                      table_client: Annotated[TableClient, Depends(get_table_client_flight)]) -> List[Flight]:
    try:
        parameters = {"country": country, "code": airport_code}
        filter = "PartitionKey eq @country and ToAirport eq @code"
        queried_entities = table_client.query_entities(query_filter=filter, parameters=parameters)        

        flights: List[Flight] = []

        async for entity in queried_entities:
            flights.append(Flight(**entity))

        return flights

    except Exception as e:
        logger.error(e)
        raise HTTPException(status_code=500, detail='Internal Server Error')