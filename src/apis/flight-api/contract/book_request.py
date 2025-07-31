from pydantic import BaseModel, Field

class BookRequest(BaseModel):
    country: str #PartitionKey
    flight_code:str = Field(alias="flightCode") #RowKey