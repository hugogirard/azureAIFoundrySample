from mcp.server.fastmcp import FastMCP
from services import AirportService, FlightService
from config import Config
from typing import List
from models import Airport, Flight

# Create an MCP server
mcp = FastMCP("Flight Booking")

config = Config()

# Declare services
airport_service = AirportService()
flight_service = FlightService()

# Add an addition tool
@mcp.tool(description="Get the list of flights for airports, origin and destination")
async def get_airports() -> List[Airport]:
    """Get the list of airports flight available"""
    return await airport_service.get_airports()

@mcp.tool(description="Get the list of flights for airports, origin and destination")
async def get_flights(country:str, airport_code:str) -> List[Flight]:    
    """
    Get the list of flights available in a country for a specific airport (airport_code) available"
    Args:
        country: country, can be Canada, USA, Mexico and France only.
        airport_code: the airport code of one of those country like YUL, NCE, FCO etc.
    """    
    return await flight_service.get_flight(country,airport_code)

def main():
   if config.is_development:
     transport = 'stdio'
   else:
     transport = 'streamable-http'
   
   mcp.run(transport=transport)

if __name__ == 'main':
   main()