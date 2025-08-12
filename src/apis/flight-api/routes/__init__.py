from .airport import router as airport_router
from .flight import router as flight_router
from .booking import router as booking_router

routes = [
    airport_router,
    flight_router,
    booking_router
]