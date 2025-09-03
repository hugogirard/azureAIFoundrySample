# 🛫 Flight Booking API Documentation

The Flight API is a comprehensive RESTful web service built with **FastAPI** that manages flight bookings, airport information, and user reservations. It provides a complete backend solution for travel applications with secure authentication and database integration.

---

## 📋 Table of Contents

- [🏗️ Architecture Overview](#️-architecture-overview)
- [🌐 API Base Information](#-api-base-information)
- [🛡️ Authentication](#️-authentication)
- [📊 Data Models](#-data-models)
- [🛩️ Airport Endpoints](#️-airport-endpoints)
- [✈️ Flight Endpoints](#️-flight-endpoints)
- [📋 Booking Endpoints](#-booking-endpoints)
- [🔧 Configuration](#-configuration)
- [🐳 Docker Support](#-docker-support)
- [📝 Testing](#-testing)

---

## 🏗️ Architecture Overview

### **Technology Stack**
- **Framework**: FastAPI (Python 3.10+)
- **Database**: Azure Table Storage (Flights & Airports) + Azure CosmosDB (Bookings)
- **Authentication**: Azure Easy Auth (X-MS-CLIENT-PRINCIPAL-NAME)
- **Dependencies**: Pydantic, Azure SDK, Python logging
- **Deployment**: Docker containers with Azure App Service

### **Project Structure**
```
src/apis/flight-api/
├── main.py                    # FastAPI application entry point
├── bootstapper.py            # Application bootstrapper
├── config.py                 # Configuration management
├── dependencies.py           # Dependency injection
├── Dockerfile                # Container configuration
├── requirements.txt          # Python dependencies
├── api.http                  # HTTP test requests
├── openapi.json             # OpenAPI specification
├── contract/                # Request/Response models
│   ├── book_request.py
│   ├── booking_info_request.py
│   └── flight_info_request.py
├── models/                  # Data models
│   ├── airport.py
│   ├── flight.py
│   └── flight_info.py
├── routes/                  # API route handlers
│   ├── airport.py
│   ├── flight.py
│   └── booking.py
├── repository/              # Data access layer
│   └── flight_repository.py
└── data/                    # Sample data files
    ├── airport.json
    └── flights.json
```

---

## 🌐 API Base Information

| Property | Value |
|----------|--------|
| **Base URL** | `http://localhost:8000` (development) |
| **API Prefix** | `/api` |
| **OpenAPI Version** | 3.1.0 |
| **Interactive Docs** | `/docs` (Swagger UI) |
| **Alternative Docs** | `/redoc` (ReDoc) |
| **OpenAPI JSON** | `/openapi.json` |

### **CORS Configuration**
- **Allowed Origins**: `*` (all origins)
- **Allowed Methods**: `*` (all methods)
- **Allowed Headers**: `*` (all headers)
- **Allow Credentials**: `true`

---

## 🛡️ Authentication

The API uses **Azure Easy Auth** for user authentication. All endpoints (except documentation) require a valid user principal.

### **Authentication Header**
```http
X-MS-CLIENT-PRINCIPAL-NAME: user@example.com
```

### **Development Mode**
For local development, set the environment variable:
```bash
IS_DEVELOPMENT=true
USER_PRINCIPAL_NAME=test@example.com
```

### **Authentication Flow**
1. Azure App Service handles authentication
2. Easy Auth injects user principal into request headers
3. API validates user principal existence
4. User principal is used for RBAC and data isolation

---

## 📊 Data Models

### **Airport Model**
Represents airport information stored in Azure Table Storage.

```python
{
    "country": "USA",           # PartitionKey
    "airport_code": "LAX",      # RowKey  
    "airport_name": "Los Angeles International Airport"
}
```

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `country` | `string` | Country code (PartitionKey) | ✅ |
| `airport_code` | `string` | IATA airport code (RowKey) | ✅ |
| `airport_name` | `string` | Full airport name | ✅ |

### **Flight Model**
Represents flight information stored in Azure Table Storage.

```python
{
    "country": "USA",                    # PartitionKey
    "flight_code": "Delta008",           # RowKey
    "airline": "Delta Airlines",
    "from_airport": "LAX",
    "to_airport": "JFK", 
    "price": 299,
    "seats_available": 150,
    "duration": "5h 30m",
    "direct_flight": true,
    "departure_time": "2024-01-15T08:00:00Z",
    "arrival_time": "2024-01-15T13:30:00Z"
}
```

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `country` | `string` | Country code (PartitionKey) | ✅ |
| `flight_code` | `string` | Unique flight identifier (RowKey) | ✅ |
| `airline` | `string` | Airline name | ✅ |
| `from_airport` | `string` | Departure airport IATA code | ✅ |
| `to_airport` | `string` | Arrival airport IATA code | ✅ |
| `price` | `integer` | Flight price | ✅ |
| `seats_available` | `integer` | Available seats count | ✅ |
| `duration` | `string` | Flight duration | ✅ |
| `direct_flight` | `boolean` | Is direct flight | ✅ |
| `departure_time` | `datetime` | Departure timestamp (ISO 8601) | ✅ |
| `arrival_time` | `datetime` | Arrival timestamp (ISO 8601) | ✅ |

### **Request/Response Models**

#### **BookRequest**
```python
{
    "country": "USA",
    "flightCode": "Delta008"
}
```

#### **BookingInfoRequest**
```python
{
    "bookingId": "uuid-string",
    "country": "USA", 
    "flightCode": "Delta008"
}
```

#### **FlightInfoRequest** (Booking Details)
```python
{
    "bookingId": "uuid-string",
    "country": "USA",
    "flightCode": "Delta008",
    "airline": "Delta Airlines",
    "from_airport": "LAX",
    "to_airport": "JFK",
    "duration": "5h 30m", 
    "direct_flight": true,
    "departure_time": "2024-01-15T08:00:00Z",
    "arrival_time": "2024-01-15T13:30:00Z"
}
```

---

## 🛩️ Airport Endpoints

### **GET /api/airport/**
Retrieve all available airports.

**Description**: Returns a complete list of all airports in the system.

**Request**:
```http
GET /api/airport/
Content-Type: application/json
X-MS-CLIENT-PRINCIPAL-NAME: user@example.com
```

**Response** (200 OK):
```json
[
    {
        "country": "USA",
        "airport_code": "LAX", 
        "airport_name": "Los Angeles International Airport"
    },
    {
        "country": "USA",
        "airport_code": "JFK",
        "airport_name": "John F. Kennedy International Airport"
    }
]
```

**Use Cases**:
- Populating airport dropdown lists
- Airport search functionality
- Travel planning interfaces

---

## ✈️ Flight Endpoints

### **GET /api/flight/country/{country}**
Retrieve all flights for a specific country.

**Description**: Returns all available flights originating from the specified country.

**Path Parameters**:
- `country` (string, required): Country code (e.g., "USA", "Canada")

**Request**:
```http
GET /api/flight/country/USA
Content-Type: application/json
X-MS-CLIENT-PRINCIPAL-NAME: user@example.com
```

**Response** (200 OK):
```json
[
    {
        "country": "USA",
        "flight_code": "Delta008",
        "airline": "Delta Airlines",
        "from_airport": "LAX",
        "to_airport": "JFK",
        "price": 299,
        "seats_available": 150,
        "duration": "5h 30m",
        "direct_flight": true,
        "departure_time": "2024-01-15T08:00:00Z",
        "arrival_time": "2024-01-15T13:30:00Z"
    }
]
```

**Use Cases**:
- Country-specific flight searches
- Regional flight availability
- Market analysis by country

---

### **GET /api/flight/{country}/{airport_code}**
Retrieve flights to a specific destination airport.

**Description**: Returns all flights from the specified country to the specified destination airport.

**Path Parameters**:
- `country` (string, required): Origin country code
- `airport_code` (string, required): Destination airport IATA code

**Request**:
```http
GET /api/flight/USA/JFK
Content-Type: application/json
X-MS-CLIENT-PRINCIPAL-NAME: user@example.com
```

**Response** (200 OK):
```json
[
    {
        "country": "USA",
        "flight_code": "Delta008", 
        "airline": "Delta Airlines",
        "from_airport": "LAX",
        "to_airport": "JFK",
        "price": 299,
        "seats_available": 150,
        "duration": "5h 30m",
        "direct_flight": true,
        "departure_time": "2024-01-15T08:00:00Z",
        "arrival_time": "2024-01-15T13:30:00Z"
    }
]
```

**Use Cases**:
- Destination-specific flight searches
- Route planning
- Price comparison for specific routes

---

### **POST /api/flight/book**
Book a flight ticket.

**Description**: Creates a new flight booking for the authenticated user and decrements available seats.

**Request Body**:
```json
{
    "country": "USA",
    "flightCode": "Delta008"
}
```

**Request**:
```http
POST /api/flight/book
Content-Type: application/json
X-MS-CLIENT-PRINCIPAL-NAME: user@example.com

{
    "country": "USA",
    "flightCode": "Delta008"
}
```

**Response** (202 Accepted):
```json
{
    "bookingId": "16ac3e2b-5c48-4fbd-9ebe-1cbb8d7d0c59",
    "country": "USA",
    "flightCode": "Delta008"
}
```

**Error Responses**:
- **400 Bad Request**: No seats available
- **401 Unauthorized**: Missing or invalid authentication
- **500 Internal Server Error**: Database or system error

**Business Logic**:
1. Validates flight exists and has available seats
2. Decrements `seats_available` by 1 
3. Creates booking record in CosmosDB
4. Returns booking confirmation

**Use Cases**:
- Flight reservation system
- Travel booking workflows
- Seat inventory management

---

### **DELETE /api/flight/cancel**
Cancel a flight booking.

**Description**: Cancels an existing booking and increments available seats.

**Request Body**:
```json
{
    "bookingId": "16ac3e2b-5c48-4fbd-9ebe-1cbb8d7d0c59",
    "country": "USA",
    "flightCode": "Delta008"
}
```

**Request**:
```http
DELETE /api/flight/cancel
Content-Type: application/json
X-MS-CLIENT-PRINCIPAL-NAME: user@example.com

{
    "bookingId": "16ac3e2b-5c48-4fbd-9ebe-1cbb8d7d0c59",
    "country": "USA", 
    "flightCode": "Delta008"
}
```

**Response** (200 OK):
```json
{}
```

**Error Responses**:
- **400 Bad Request**: Cannot cancel (seats at maximum capacity)
- **401 Unauthorized**: Missing or invalid authentication
- **404 Not Found**: Booking not found
- **500 Internal Server Error**: Database or system error

**Business Logic**:
1. Validates booking exists and belongs to user
2. Increments `seats_available` by 1
3. Deletes booking record from CosmosDB
4. Returns success confirmation

**Use Cases**:
- Booking cancellation workflows
- Refund processing
- Seat inventory management

---

## 📋 Booking Endpoints

### **GET /api/booking/all**
Get all bookings for the authenticated user.

**Description**: Retrieves all flight bookings made by the current user with complete flight details.

**Request**:
```http
GET /api/booking/all
Content-Type: application/json
X-MS-CLIENT-PRINCIPAL-NAME: user@example.com
```

**Response** (200 OK):
```json
[
    {
        "bookingId": "16ac3e2b-5c48-4fbd-9ebe-1cbb8d7d0c59",
        "country": "USA",
        "flightCode": "Delta008",
        "airline": "Delta Airlines",
        "from_airport": "LAX",
        "to_airport": "JFK", 
        "duration": "5h 30m",
        "direct_flight": true,
        "departure_time": "2024-01-15T08:00:00Z",
        "arrival_time": "2024-01-15T13:30:00Z"
    }
]
```

**Performance Optimization**:
- Single optimized query for all user bookings
- Batch flight information retrieval
- O(1) lookup dictionary for flight details

**Use Cases**:
- User booking history
- Trip management dashboards
- Booking confirmation emails

---

### **GET /api/booking/{booking_id}**
Get detailed information for a specific booking.

**Description**: Retrieves complete booking and flight information for a specific booking ID.

**Path Parameters**:
- `booking_id` (string, required): Unique booking identifier

**Request**:
```http
GET /api/booking/16ac3e2b-5c48-4fbd-9ebe-1cbb8d7d0c59
Content-Type: application/json
X-MS-CLIENT-PRINCIPAL-NAME: user@example.com
```

**Response** (200 OK):
```json
{
    "bookingId": "16ac3e2b-5c48-4fbd-9ebe-1cbb8d7d0c59",
    "country": "USA", 
    "flightCode": "Delta008",
    "airline": "Delta Airlines",
    "from_airport": "LAX",
    "to_airport": "JFK",
    "duration": "5h 30m",
    "direct_flight": true,
    "departure_time": "2024-01-15T08:00:00Z",
    "arrival_time": "2024-01-15T13:30:00Z"
}
```

**Error Responses**:
- **401 Unauthorized**: Missing or invalid authentication
- **404 Not Found**: Booking not found or doesn't belong to user
- **500 Internal Server Error**: Database or system error

**Use Cases**:
- Booking detail views
- Confirmation pages
- Customer service inquiries

---

## 🔧 Configuration

### **Environment Variables**

The API requires the following environment variables:

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `AZURE_STORAGE_ENDPOINT` | Azure Storage account endpoint | `https://mystorageaccount.table.core.windows.net/` | ✅ |
| `AZURE_STORAGE_AIRPORT_TABLE` | Airport table name | `airporttable` | ✅ |
| `AZURE_STORAGE_FLIGHT_TABLE` | Flight table name | `flighttable` | ✅ |
| `STORAGE_ACCESS_KEY` | Storage account access key | `key123...` | ✅ |
| `AZURE_STORAGE_CONNECTION_STRING` | Storage connection string | `DefaultEndpointsProtocol=https;...` | ✅ |
| `AZURE_COSMOSDB_ENDPOINT` | CosmosDB endpoint URL | `https://mycosmosdb.documents.azure.com:443/` | ✅ |
| `COSMOS_DATABASE` | CosmosDB database name | `flight` | ✅ |
| `COSMOS_CONTAINER` | CosmosDB container name | `bookings` | ✅ |
| `IS_DEVELOPMENT` | Development mode flag | `false` | ❌ |
| `USER_PRINCIPAL_NAME` | Dev user principal | `test@example.com` | ❌ |

### **Configuration Class**
```python
class Config:
    @property
    def storage_endpoint(self) -> str:
        return os.getenv('AZURE_STORAGE_ENDPOINT')
    
    @property
    def is_development(self) -> bool:
        value = os.getenv('IS_DEVELOPMENT', 'false').lower()
        return value in ['true', '1', 'yes']
```

---

## 🐳 Docker Support

### **Dockerfile**
The API includes Docker support for containerized deployment:

```dockerfile
# Multi-stage build with Python 3.10
FROM python:3.10-slim

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port 8000
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### **Building and Running**
```bash
# Build the Docker image
docker build -t flight-api .

# Run the container
docker run -p 8000:8000 \
  -e AZURE_STORAGE_ENDPOINT=https://mystorageaccount.table.core.windows.net/ \
  -e AZURE_STORAGE_AIRPORT_TABLE=airporttable \
  -e AZURE_STORAGE_FLIGHT_TABLE=flighttable \
  -e STORAGE_ACCESS_KEY=your-storage-key \
  -e AZURE_COSMOSDB_ENDPOINT=https://mycosmosdb.documents.azure.com:443/ \
  -e COSMOS_DATABASE=flight \
  -e COSMOS_CONTAINER=bookings \
  flight-api
```

---

## 📝 Testing

### **HTTP Test File**
The API includes a comprehensive `api.http` file for testing all endpoints:

```http
### Variables
@baseUrl = http://localhost:8000
@userPrincipalName = test@example.com

### Get all airports
GET {{baseUrl}}/api/airport/
X-MS-CLIENT-PRINCIPAL-NAME: {{userPrincipalName}}

### Get flights by country
GET {{baseUrl}}/api/flight/country/USA
X-MS-CLIENT-PRINCIPAL-NAME: {{userPrincipalName}}

### Book a flight
POST {{baseUrl}}/api/flight/book
Content-Type: application/json
X-MS-CLIENT-PRINCIPAL-NAME: {{userPrincipalName}}

{
  "country": "USA",
  "flightCode": "Delta008"
}
```

### **Sample Data**
The API includes sample data files:
- `data/airport.json`: Sample airport data
- `data/flights.json`: Sample flight data

### **Testing Scenarios**
1. **Airport Management**: Test airport listing functionality
2. **Flight Search**: Test country and destination-based searches
3. **Booking Flow**: Test complete booking and cancellation workflow
4. **User Authentication**: Test authentication requirements
5. **Error Handling**: Test various error scenarios
6. **Performance**: Test with multiple concurrent bookings

---

## 🚀 Deployment Architecture

### **Azure Integration**
- **Azure App Service**: Host the FastAPI application
- **Azure Table Storage**: Store airport and flight data
- **Azure CosmosDB**: Store booking information
- **Azure Easy Auth**: Handle user authentication
- **Azure Application Insights**: Monitor application performance

### **Security Features**
- **No public endpoints**: All endpoints require authentication
- **User isolation**: Bookings are isolated by user principal
- **CORS enabled**: Supports web applications
- **Input validation**: Pydantic models ensure data integrity
- **Error handling**: Comprehensive error responses

### **Scalability Considerations**
- **Horizontal scaling**: Stateless design supports multiple instances
- **Database optimization**: Optimized queries with batch operations
- **Caching**: Consider Azure Redis Cache for frequent data
- **Connection pooling**: Reuse database connections

---

## 🛠️ Development Setup

### **Local Development**
1. **Clone the repository**
2. **Install dependencies**: `pip install -r requirements.txt`
3. **Set environment variables** (see Configuration section)
4. **Run the application**: `uvicorn main:app --reload`
5. **Access documentation**: `http://localhost:8000/docs`

### **Development Tools**
- **FastAPI**: Web framework with automatic API documentation
- **Pydantic**: Data validation and serialization
- **Azure SDK**: Azure service integration
- **Uvicorn**: ASGI server for development and production

### **Code Quality**
- **Type hints**: Full type annotation support
- **Error handling**: Comprehensive exception handling
- **Logging**: Structured logging throughout the application
- **Documentation**: Inline documentation and OpenAPI specs

---

## 📚 API Reference Summary

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/airport/` | List all airports | ✅ |
| `GET` | `/api/flight/country/{country}` | Get flights by country | ✅ |
| `GET` | `/api/flight/{country}/{airport_code}` | Get flights to destination | ✅ |
| `POST` | `/api/flight/book` | Book a flight | ✅ |
| `DELETE` | `/api/flight/cancel` | Cancel a booking | ✅ |
| `GET` | `/api/booking/all` | Get user's all bookings | ✅ |
| `GET` | `/api/booking/{booking_id}` | Get specific booking | ✅ |

### **Response Codes**
- `200` - Success (GET, DELETE operations)
- `202` - Accepted (POST booking operations)
- `400` - Bad Request (validation errors, business logic errors)
- `401` - Unauthorized (missing or invalid authentication)
- `404` - Not Found (resource not found)
- `422` - Validation Error (request body validation failed)
- `500` - Internal Server Error (system errors)

---

This comprehensive API provides a robust foundation for flight booking applications with secure user authentication, efficient data management, and scalable architecture suitable for production deployment on Azure.
