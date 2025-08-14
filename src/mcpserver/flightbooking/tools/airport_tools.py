from typing import List
from models import Airport
from services import AirportService
from .base_tools import BaseTools

class AirportTools(BaseTools):
    """Class containing all airport-related MCP tools"""
    
    def __init__(self):
        self.airport_service = AirportService()

    async def get_airports(self) -> List[Airport]:
        """Get the list of airports flight available"""
        return await self.airport_service.get_airports()