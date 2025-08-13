from contextlib import asynccontextmanager
from azure.data.tables.aio import TableClient, TableServiceClient
from azure.identity.aio import DefaultAzureCredential
from azure.cosmos.aio import CosmosClient
from repository.flight_repository import FlightRepository
from fastapi import FastAPI
from config import Config

config = Config()

@asynccontextmanager
async def lifespan_event(app: FastAPI):
    
    table_service_client = TableServiceClient(endpoint=config.storage_endpoint,credential=DefaultAzureCredential())
    app.state.table_client_airport = table_service_client.get_table_client(table_name=config.airport_table)
    app.state.table_client_flight = table_service_client.get_table_client(table_name=config.flight_table)

    # Create cosmosdb repository
    credential = DefaultAzureCredential()
    cosmos_client = CosmosClient(url=config.cosmos_endpoint,
                                 credential=credential)
    
    container = cosmos_client.get_database_client(config.cosmos_database).get_container_client(config.cosmos_container)

    app.state.repository = FlightRepository(container)

    yield

class Boostrapper:

    def run(self) -> FastAPI:

        app = FastAPI(lifespan=lifespan_event,
                      title="Flight Booking API",
                      description="API for managing flights bookings",
                      version="1.0.0")
     
        self._configure_monitoring(app)
        
        return app
     
    def _configure_monitoring(self, app: FastAPI):
        ...