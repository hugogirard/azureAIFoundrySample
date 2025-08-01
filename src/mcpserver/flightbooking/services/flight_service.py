from typing import List
from models import Flight
from config import Config
import aiohttp
import asyncio

class FlightService:

    def __init__(self):
        self.config = Config()

    async def get_flight_by_country(self,country:str)  -> List[Flight]:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.config.booking_api_url}/api/flight/country/{country}/") as response:
                json_data = await response.json()
                return [Flight(**flight_data) for flight_data in json_data]          

    async def get_flight(self,country:str,airport_code:str) -> List[Flight]:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.config.booking_api_url}/api/flight/{country}/{airport_code}") as response:
                json_data = await response.json()
                return [Flight(**flight_data) for flight_data in json_data]            

    async def book_flight(self,country:str, flight_code:str) -> None:
        async with aiohttp.ClientSession() as session:
            async with session.post(f"{self.config.booking_api_url}/api/flight/",json={
                'country': country,
                'flightCode': flight_code
            }) as response:
                if response.status != 202:
                    raise Exception(f"Failed to book flight: {response.status} - {await response.text()}")

    async def cancel_flight(self,country:str, flight_code:str) -> None:
        async with aiohttp.ClientSession() as session:
            async with session.delete(f"{self.config.booking_api_url}/api/flight/",json={
                'country': country,
                'flightCode': flight_code
            }) as response:
                if response.status != 204:
                    raise Exception(f"Failed to cancel flight: {response.status} - {await response.text()}")                     