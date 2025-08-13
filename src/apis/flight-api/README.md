

```
export PYTHONPATH=$(pwd)
uv pip compile pyproject.toml -o requirements.txt
uv pip install -r requirements.txt
```

https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/how-to-grant-control-plane-access?tabs=built-in-definition%2Ccsharp&pivots=azure-interface-cli