from fastapi import APIRouter, Depends, HTTPException
from azure.data.tables.aio import TableClient
from dependencies import get_table_client_flight, get_logger, get_booking_repository, get_easy_auth_token
from repository.flight_repository import FlightRepository
from logging import Logger
from contract import FlightInfoRequest
from typing import Annotated, List
from models import Flight

router = APIRouter(prefix="/booking")

@router.get('/all',description="Get all bookings for a specific user")
async def get_all_bookings(logger: Annotated[Logger, Depends(get_logger)],
                           repository: Annotated[FlightRepository, Depends(get_booking_repository)],
                           table_client: Annotated[TableClient, Depends(get_table_client_flight)],
                           user_principal_name: Annotated[str,Depends(get_easy_auth_token)]) -> List[FlightInfoRequest]:
   try:
      bookings = await repository.get_bookings(user_principal_name)
      
      if not bookings:
          return []
      
      # Build a single query filter for all flights to minimize database calls
      flight_filters = []
      for booking in bookings:
          flight_filters.append(f"(PartitionKey eq '{booking.country}' and RowKey eq '{booking.flight_code}')")
      
      # Single query to get all flights
      combined_filter = " or ".join(flight_filters)
      queried_entities = table_client.query_entities(query_filter=combined_filter)
      
      # Create a lookup dictionary for O(1) access
      flights_lookup = {}
      async for entity in queried_entities:
          key = f"{entity['PartitionKey']}_{entity['RowKey']}"
          flights_lookup[key] = Flight(**entity)
      
      # Build the response list
      flight_info_requests = []
      for booking in bookings:
          flight_key = f"{booking.country}_{booking.flight_code}"
          flight = flights_lookup.get(flight_key)
          
          if flight:
              flight_info_requests.append(FlightInfoRequest(
                  bookingId=booking.id,
                  country=booking.country,
                  flightCode=booking.flight_code,
                  airline=flight.Airline,
                  from_airport=flight.FromAirport,
                  to_airport=flight.ToAirport,
                  duration=flight.Duration,
                  direct_flight=flight.DirectFlight,
                  departure_time=flight.DepartureTime,
                  arrival_time=flight.ArrivalTime
              ))
          else:
              logger.warning(f"Flight not found for booking {booking.id}: {booking.country}/{booking.flight_code}")
      
      return flight_info_requests

   except Exception as e:
      logger.error(e)
      raise HTTPException(status_code=500, detail='Internal Server Error')          

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
            flight = Flight(**entity)
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