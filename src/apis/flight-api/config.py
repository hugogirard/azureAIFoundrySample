from dotenv import load_dotenv
import os

load_dotenv(override=True)

class Config:

    @property
    def storage_endpoint(self) -> str:
        return os.getenv('AZURE_STORAGE_ENDPOINT')
    
    @property
    def airport_table(self) -> str:
        return os.getenv('AZURE_STORAGE_AIRPORT_TABLE')
    
    @property
    def flight_table(self) -> str:
        return os.getenv('AZURE_STORAGE_FLIGHT_TABLE')

    @property
    def is_development(self) -> bool:
        value = os.getenv('IS_DEVELOPMENT', 'false').lower()
        return value in ['true', '1', 'yes']    
    
    @property
    def storage_access_key(self) -> str:
        return os.getenv('STORAGE_ACCESS_KEY')
    
    @property
    def storage_connection_string(self) -> str:
        return os.getenv('AZURE_STORAGE_CONNECTION_STRING')

    @property
    def cosmos_endpoint(self) -> str:
        return os.getenv('AZURE_COSMOSDB_ENDPOINT')