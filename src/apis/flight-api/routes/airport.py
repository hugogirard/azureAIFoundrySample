from fastapi import APIRouter, Depends, HTTPException, Header
from azure.data.tables.aio import TableClient
from dependencies import get_table_client_airport
from typing import List, Annotated
from models import Airport

router = APIRouter(prefix="/airport")

@router.get("/",description="Return the list of all the airport")
async def get_airport(table_client: Annotated[TableClient, Depends(get_table_client_airport)]) -> List[Airport]:
    entities = table_client.query_entities("")
    airports:List[Airport] = []
    async for entity in entities:
        airport = Airport(
            country=entity.get("PartitionKey"),
            airport_code=entity.get("RowKey"),
            airport_name=entity.get("AirportName")
        )
        airports.append(airport)
    return airports        