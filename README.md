# ChowChaser
## Introduction
ChowChaser is a Phoenix-based web application designed to help food enthusiasts locate food trucks in San Francisco. It leverages geospatial data to provide users with an easy way to find food trucks near a given location, synchronized with the most recent city's open data on food trucks.

## Showcase


## Features
- [x] List Food Trucks in San Francisco filtered by:
  - [x] Food trucks near a given location
- [x] Periodically synchronizes the internal database with the `Mobile Food Facility Permit` open data
  - [x] Integrates with the [open data resource](https://data.sfgov.org/resource/rqzj-sfat/) using [exsoda](https://hex.pm/packages/exsoda) library
  - [x] Inserts/updates `trucks` based on their `locationid` identifiers
  - [x] Uses [oban](https://hex.pm/packages/oban) to run the asynchronous jobs
- [x] Uses PostGIS exstension to encode the geospatial data from the food trucks in the database
  - [x] Geocodes locations using [geocoder](https://hex.pm/packages/geocoder) library
  - [x] Perform geospatial queries with [geo_postgis](https://hex.pm/packages/geo_postgis) library

## TO-DO
- [ ] Deploy the application to fly.io
- [ ] Search by Applicant name
- [ ] Search by Food items sold
- [ ] Allow users to pick the maximum distance from their location

## Architecture overview
### Design choices
- **Framework**: Built using the Phoenix framework.
- **Database** Operations: Heavily relies on Ecto for database operations.
- **Scaffolding**: Used generators to scaffold the application whenever possible, allowing developers to focus on business logic.
- **Database**: PostgreSQL with the PostGIS extension to store the food trucks and their locations.
- **API** Interaction: Exsoda library to interact with the open data API.
- **Asynchronous Jobs**: Oban library to run asynchronous jobs that synchronize the food trucks with the open data.
- **Geocoding**: Geocoding is done using the Geocoder library and the free OpenStreetMap provider.
- **Containerization**: The application is containerized using Docker and docker-compose for easy deployment.

### Trade offs
- The application is not fault tolerant in case of geocoding provider outages
- The application does not have a RESTful API to expose the food trucks
- The application does not have a map visualization of the food trucks

### Future work
- **API Enhancements:** Expose a RESTful API for better integrations, including pagination capabilities and API keys with rate limiting.
- **Geocoding Resilience:** Enhance the geocoding implementation to be fault-tolerant in case of provider outages.
- **Visualization:** Include a map visualization of the food trucks.
- **Social Features:** Allow users to rate and review food trucks, mark them as favorites, and share them with friends.
- **Data Cleaning:** Improve on cleaning up food items by aggregating similar types (e.g., rice dishes, rice krispies, rice noodles, rice plates, etc.).

## Setting up
### Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Ports 4000 and 5432 available

### Running the server

Use `docker-compose` to start the server locally:
```bash
docker-compose up -d
```
Visit the page in http://localhost:4000
