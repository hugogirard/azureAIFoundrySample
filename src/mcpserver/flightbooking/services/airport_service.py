from typing import List
from models import Airport
from config import Config
import aiohttp
import asyncio

class AirportService:

    def __init__(self):
        self.config = Config()

    async def get_airports(self) -> List[Airport]:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.config.booking_api_url}/api/airport/") as response:
                json_data = await response.json()
                return [Airport(**airport_data) for airport_data in json_data]            