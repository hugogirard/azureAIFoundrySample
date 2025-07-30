from pydantic import BaseModel, Field

class Airport(BaseModel):
    PartitionKey: str = Field(..., alias="country")
    RowKey: str = Field(..., alias="airport_code")
    AirportName: str = Field(..., alias="airport_name")

    class Config:
        allow_population_by_field_name = True