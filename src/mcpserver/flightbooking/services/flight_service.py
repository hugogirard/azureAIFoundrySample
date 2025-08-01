from typing import List
from models import Flight
from config import Config
import aiohttp
import asyncio

class FlightService:

    def __init__(self):
        self.config = Config()

    async def get_flight(self,country:str,airport_code:str) -> List[Flight]:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.config.booking_api_url}/api/flight/{country}/{airport_code}") as response:
                json_data = await response.json()
                return [Flight(**flight_data) for flight_data in json_data]            