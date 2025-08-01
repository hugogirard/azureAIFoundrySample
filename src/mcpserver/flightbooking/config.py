from dotenv import load_dotenv
import os

class Config:

    def __init__(self):
        load_dotenv(override=True)

    @property
    def booking_api_url(self) -> str:
        return os.getenv('FLIGHT_BOOKING_URL')
    
    @property
    def is_development(self) -> bool:
        value = os.getenv('IS_DEVELOPMENT', 'false').lower()
        return value in ['true', '1', 'yes']        