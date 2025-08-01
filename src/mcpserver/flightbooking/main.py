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

@mcp.tool(description="Get the list of flights for a specific country")
async def get_flight_by_country(country:str) -> List[Flight]:
    """Get the list of flights for a specific country
       Args:
        country: country, can be Canada, USA, Mexico and France only.
    """
    return await flight_service.get_flight_by_country(country)

@mcp.tool(description="Get the list of flights for airports, origin and destination")
async def get_airports() -> List[Airport]:
    """Get the list of airports flight available"""
    return await airport_service.get_airports()

@mcp.tool(description="Get the list of flights for a specific airport")
async def get_flights_by_airport(country:str, airport_code:str) -> List[Flight]:    
    """
    Get the list of flights available in a country for a specific airport (airport_code) available"
    Args:
        country: country, can be Canada, USA, Mexico and France only.
        airport_code: the airport code of one of those country like YUL, NCE, FCO etc.
    """    
    return await flight_service.get_flight(country,airport_code)

@mcp.tool(description="Book a flight to a specific country using the flight_code")
async def book_flight(country:str, flight_code:str) -> None:    
    """
    Book a flight to a specific country using the flight_code"
    Args:
        country: country, can be Canada, USA, Mexico and France only.
        flight_code: The flight code to origin and destination, used to book the flight
    """    
    return await flight_service.book_flight(country,flight_code)

@mcp.tool(description="Cancel a flight to a specific country using the flight_code")
async def book_flight(country:str, flight_code:str) -> None:    
    """
    Cancel a flight to a specific country using the flight_code"
    Args:
        country: country, can be Canada, USA, Mexico and France only.
        flight_code: The flight code to origin and destination, used to book the flight
    """    
    return await flight_service.cancel_flight(country,flight_code)

if __name__ == '__main__':
   mcp.run(transport='streamable-http')