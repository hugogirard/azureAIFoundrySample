from contextlib import asynccontextmanager
from azure.data.tables.aio import TableClient
from fastapi import FastAPI
from config import Config

config = Config()

@asynccontextmanager
async def lifespan_event(app: FastAPI):
    
    if config.is_development:
      table_client_airport = TableClient.from_connection_string(config.storage_connection_string,config.airport_table)
      app.state.table_client_airport = table_client_airport      
    else:
      pass
    
    yield

class Boostrapper:

    def run(self) -> FastAPI:

        app = FastAPI(lifespan=lifespan_event)
     
        self._configure_monitoring(app)

        return app
     
    def _configure_monitoring(self, app: FastAPI):
        ...