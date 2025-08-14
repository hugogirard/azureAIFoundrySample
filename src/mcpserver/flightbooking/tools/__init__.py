from .base_tools import BaseTools
from .airport_tools import AirportTools

# Registry of all tool classes
TOOL_CLASSES = [
    AirportTools
]

def register_all_tools(mcp_instance):
    """Register all tools from all tool classes"""
    for tool_class in TOOL_CLASSES:
        tool_class.register_all_tools(mcp_instance)