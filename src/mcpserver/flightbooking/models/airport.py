from pydantic import BaseModel, Field

class Airport(BaseModel):
    country: str = Field(..., alias="country")
    airportCode: str = Field(..., alias="airport_code")
    airportName: str = Field(..., alias="airport_name")