from fastapi import APIRouter, Depends, HTTPException
from azure.data.tables.aio import TableClient
from dependencies import get_table_client_flight, get_logger
from azure.data.tables import UpdateMode
from logging import Logger
from contract import BookRequest
from typing import List, Annotated
from models import Flight

router = APIRouter(prefix="/flight")


@router.get('/country/{country}')
async def flight_by_country(country:str,
                            logger: Annotated[Logger, Depends(get_logger)],
                            table_client: Annotated[TableClient, Depends(get_table_client_flight)]) -> List[Flight]:
    try:
        parameters = {"country": country}
        filter = "PartitionKey eq @country"
        queried_entities = table_client.query_entities(query_filter=filter, parameters=parameters)        

        flights: List[Flight] = []

        async for entity in queried_entities:
            flights.append(Flight(**entity))

        return flights       
    except Exception as e:
      logger.error(e)
      raise HTTPException(status_code=500, detail='Internal Server Error')        

@router.get("/{country}/{airport_code}",description="Return the list of all flight for a specific destination")
async def flight_by_airport(country: str,
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
    
@router.post("/book",description="Book a flight ticket")
async def book_flight(book_request:BookRequest,
                      logger: Annotated[Logger, Depends(get_logger)],
                      table_client: Annotated[TableClient, Depends(get_table_client_flight)]):
    try:
            
      await update_flight_seat(book_request=book_request,
                               table_client=table_client,
                               mode=UpdateMode.REPLACE)
      
      return {"message": "Flight booked successfully"}, 202
    
    except Exception as e:
      logger.error(e)
      raise HTTPException(status_code=500, detail='Internal Server Error')        

@router.delete("/cancel",description="Cancel flight")    
async def cancel_flight(book_request:BookRequest,
                        logger: Annotated[Logger, Depends(get_logger)],
                        table_client: Annotated[TableClient, Depends(get_table_client_flight)]):
    try:
      await update_flight_seat(book_request=book_request,
                               table_client=table_client)
      return {"message": "Flight cancelled successfully"}, 204    
    except Exception as e:
      logger.error(e)
      raise HTTPException(status_code=500, detail='Internal Server Error')         
    
async def update_flight_seat(book_request:BookRequest,
                             table_client:TableClient,
                             mode: str = "DELETE"):
    
    flight = await table_client.get_entity(partition_key=book_request.country, row_key=book_request.flight_code)
    seats_available = flight.get('SeatsAvailable', 0)
    max_seat_capacity = flight.get('MaxSeatCapacity', 0)

    if mode == "UPDATE":
        if seats_available > 0:
            flight['SeatsAvailable'] = seats_available - 1
        else:
            raise HTTPException(status_code=400, detail='No seats available')
    else:
        if seats_available < max_seat_capacity:
            flight['SeatsAvailable'] = seats_available + 1
        else:
            raise HTTPException(status_code=400, detail='Cannot cancel: seats already at maximum capacity')

    await table_client.upsert_entity(mode=UpdateMode.REPLACE, entity=flight)