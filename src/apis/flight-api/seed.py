# Sample
# https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/tables/azure-data-tables/samples

from azure.data.tables import TableServiceClient, TableClient
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv
from config import Config
import json
import os
import time

def delete_table() -> bool:
    value = os.getenv('DELETE_TABLE', 'false').lower()
    return value in ['true', '1', 'yes']       

try:

    load_dotenv(override=True)

    config = Config()
    table_service_client = TableServiceClient(endpoint=config.storage_endpoint,credential=DefaultAzureCredential())
    
    try:
        if delete_table():
            print(f"Deleting table {config.airport_table}...")
            table_service_client.delete_table(table_name=config.airport_table)
            table_service_client.delete_table(table_name=config.flight_table)
            time.sleep(120)
    except Exception as e:
        print(f"Delete table failed: {e}")    

    table_service_client.create_table_if_not_exists(table_name=config.airport_table)
    table_service_client.create_table_if_not_exists(table_name=config.flight_table)

    table_client_airport = table_service_client.get_table_client(table_name=config.airport_table)
    table_client_flight = table_service_client.get_table_client(table_name=config.flight_table)

    # Load JSON file
    with open("data/airport.json", "r") as f:
        airports = json.load(f)

    # Insert each airport entity into the table
    for airport in airports:
        table_client_airport.create_entity(entity=airport)

    with open("data/flights.json", "r") as f:
        flights = json.load(f)

    # Insert each airport entity into the table
    for flight in flights:
        table_client_flight.create_entity(entity=flight)    

    print(f"Seeded {len(airports)} airports to Azure Table Storage.")
    print(f"Seeded {len(flights)} flights to Azure Table Storage.")

    exit(0)
except Exception as e:
    print(f"Script failed: {e}")
    exit(1)