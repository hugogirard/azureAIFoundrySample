# Sample
# https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/tables/azure-data-tables/samples

from azure.data.tables import TableServiceClient, TableClient
from azure.identity import DefaultAzureCredential
from config import Config
import json

config = Config()

table_service_client = TableServiceClient.from_connection_string(config.storage_connection_string)

table_service_client.create_table_if_not_exists(table_name=config.airport_table)

table_client = table_service_client.get_table_client(table_name=config.airport_table)

# Load JSON file
with open("data/airport.json", "r") as f:
    airports = json.load(f)

# Insert each airport entity into the table
for airport in airports:
    table_client.create_entity(entity=airport)

print(f"Seeded {len(airports)} airports to Azure Table Storage.")
