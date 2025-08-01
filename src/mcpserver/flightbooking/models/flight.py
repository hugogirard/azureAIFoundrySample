from pydantic import BaseModel, Field
from datetime import datetime

class Flight(BaseModel):
    country: str = Field(..., alias="country")
    flightCode: str = Field(..., alias="flight_code")
    airline: str = Field(..., alias="airline")
    fromAirport: str = Field(..., alias="from_airport")
    toAirport: str = Field(..., alias="to_airport")
    price: float = Field(..., alias="price")
    seatsAvailable: int = Field(..., alias="seats_available")
    duration: str = Field(..., alias="duration")
    directFlight: bool = Field(..., alias="direct_flight")
    departureTime: datetime = Field(..., alias="departure_time")
    arrivalTime: datetime = Field(..., alias="arrival_time")
