from fastapi import APIRouter, Depends, HTTPException
from azure.data.tables.aio import TableClient
from dependencies import get_table_client_flight, get_logger, get_booking_repository, get_easy_auth_token
from repository.flight_repository import FlightRepository
from logging import Logger
from contract import FlightInfoRequest
from typing import Annotated
from models import Flight

router = APIRouter(prefix="/booking")

@router.get('/{booking_id}')
async def get_booking_info(booking_id:str,
                           logger: Annotated[Logger, Depends(get_logger)],
                           repository: Annotated[FlightRepository, Depends(get_booking_repository)],
                           table_client: Annotated[TableClient, Depends(get_table_client_flight)],
                           user_principal_name: Annotated[str,Depends(get_easy_auth_token)]) -> FlightInfoRequest:
    try:
        flight_info = await repository.get_booking(booking_id,user_principal_name)

        if flight_info is None:
          raise HTTPException(status_code=404, detail='Booking not found')
        
        parameters = {"country": flight_info.country, "flight_code": flight_info.flight_code}
        filter = "PartitionKey eq @country and RowKey eq @flight_code"
        queried_entities = table_client.query_entities(query_filter=filter, parameters=parameters)           

        flight: Flight = None

        async for entity in queried_entities:
            flight.append(Flight(**entity))
            break # Always return 1 entity anyway
        
        if flight is None:
           raise HTTPException(status_code=404, detail='Flight cannot be found')
        
        return FlightInfoRequest(
           bookingId=booking_id,
           country=flight_info.country,
           flightCode=flight_info.flight_code,
           airline=flight.Airline,
           from_airport=flight.FromAirport,
           to_airport=flight.ToAirport,
           duration=flight.Duration,
           direct_flight=flight.DirectFlight,
           departure_time=flight.DepartureTime,
           arrival_time=flight.ArrivalTime
        )

    except Exception as e:
      logger.error(e)
      raise HTTPException(status_code=500, detail='Internal Server Error')    