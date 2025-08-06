from azure.cosmos.aio import ContainerProxy
from models import FlightInfo

class FlightRepository:
    def __init__(self,container:ContainerProxy):
        self.container = container
    
    async def book_flight(country:str,flight_code:str,username:str) -> FlightInfo:
        pass
