from azure.cosmos.aio import ContainerProxy
from models import FlightInfo
from typing import List
import uuid

class FlightRepository:
    def __init__(self,container:ContainerProxy):
        self.container = container
    
    async def book_flight(self,country:str,flight_code:str,username:str) -> FlightInfo:
        guid = str(uuid.uuid4())
        flight_info = FlightInfo(
            guid,
            country,
            flight_code,
            username
        ) 
        await self.container.create_item(flight_info.model_dump(by_alias=True))
        return flight_info        

    async def delete_booking(self, id:str, user_name:str) -> None:
        try:            
            await self.container.delete_item(item=id,partition_key=user_name)    
        except Exception:
            pass
    
    async def get_bookings(self, user_name:str) -> List[FlightInfo]:
        bookings = []
        query = "SELECT DISTINCT * FROM c where c.username = @username"
        async for item in self.container.query_items(query=query,
                                                     parameters=[{"name": "@username", "value": str(user_name)}]):
            booking = FlightInfo.model_validate(item)
            bookings.append(booking)
        return bookings             
    
    async def get_booking(self, id:str, user_name:str) -> FlightInfo:
        query = "SELECT * FROM c where c.id = @id AND c.username = @username"
        async for item in self.container.query_items(query=query,
                                                     parameters=[{"name": "@username", "value": str(user_name)},
                                                                 {"id": "@id", "value": id}]):
            return FlightInfo.model_validate(item)
        
        return None