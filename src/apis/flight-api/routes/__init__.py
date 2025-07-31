from .airport import router as airport_router
from .flight import router as flight_router

routes = [
    airport_router,
    flight_router
]