import inspect
from abc import ABC
from mcp.server.fastmcp import FastMCP

class BaseTools(ABC):
    """Base class for all MCP tool classes"""
    
    @classmethod
    def register_all_tools(cls, mcp_instance: FastMCP):
        """Use reflection to register all public methods as MCP tools"""
        tools_instance = cls()
        
        # Get all methods from the class
        for method_name, method in inspect.getmembers(tools_instance, predicate=inspect.iscoroutinefunction):
            # Skip private methods and the register_all_tools method itself
            if not method_name.startswith('_') and method_name != 'register_all_tools':
                # Get the method's docstring for description
                description = method.__doc__ or f"Tool: {method_name}"
                
                mcp_instance.add_tool(method,description=description)

                # Register the method as an MCP tool using the decorator approach
                #decorated_method = mcp_instance.tool(description=description)(method)
                
                print(f"Registered {cls.__name__} tool: {method_name}")