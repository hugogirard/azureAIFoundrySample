from pydantic import BaseModel, Field
from datetime import datetime

class FlightInfoRequest(BaseModel):
    id: str = Field(default=None, alias="bookingId")
    country: str
    flight_code: str = Field(default=None, alias='flightCode')
    Airline: str = Field(..., alias="airline")
    FromAirport: str = Field(..., alias="from_airport")
    ToAirport: str = Field(..., alias="to_airport")
    Duration: str = Field(..., alias="duration")
    DirectFlight: bool = Field(..., alias="direct_flight")
    DepartureTime: datetime = Field(..., alias="departure_time")
    ArrivalTime: datetime = Field(..., alias="arrival_time")    