from pydantic import BaseModel, Field

class BookingInfoRequest(BaseModel):
    id: str = Field(default=None, alias="bookingId")
    country: str
    flight_code: str = Field(default=None, alias='flightCode')