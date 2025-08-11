from pydantic import BaseModel, Field

class FlightInfo(BaseModel):
    id: str
    country: str
    flight_code: str = Field(default=None, alias='flightCode')
    username: str # Partition Key