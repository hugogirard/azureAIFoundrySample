```
mcp
mcp dev main.py
```

# How to test it

### MCP Inspector

First run the mcp server

```
uv run main.py
```

Next you need to start the mcp inspector
```
mcp dev main.py
```

Now you can just use the streamable http the endpoint is

```
http://localhost:8000/mcp
```

### Use VS Code

Create a folder called **.vscode** and inside of it a file called **mcp.json**.

Here the configuration

```
{
	"servers": {
		"flightbooking": {
			"url": "http://localhost:8000/mcp",
			"type": "http"
		}
	},
	"inputs": []
}
```

