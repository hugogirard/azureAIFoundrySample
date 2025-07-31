from pydantic import BaseModel, Field
from datetime import datetime

class Flight(BaseModel):
    PartitionKey: str = Field(..., alias="country")
    RowKey: str = Field(..., alias="flight_code")
    Airline: str = Field(..., alias="airline")
    FromAirport: str = Field(..., alias="from_airport")
    ToAirport: str = Field(..., alias="to_airport")
    Price: int = Field(..., alias="price")
    SeatsAvailable: int = Field(..., alias="seats_available")
    Duration: str = Field(..., alias="duration")
    DirectFlight: bool = Field(..., alias="direct_flight")
    DepartureTime: datetime = Field(..., alias="departure_time")
    ArrivalTime: datetime = Field(..., alias="arrival_time")

    class Config:
        allow_population_by_field_name = True
        populate_by_name = True
