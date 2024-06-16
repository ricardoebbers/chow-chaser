# ChowChaser
## Screenshots/gifs/videos

## Features
- [x] List Food Trucks in San Francisco filtered by:
  - [x] Food trucks near a given location and linear distance from it
  - [x] Applicant name
  - [x] Food items sold
  - [x] Status of the permit (`Approved`, `Expired`, `Issued`, `Requested` or `Suspend` (sic))
- [x] Periodically synchronizes the internal database with the `Mobile Food Facility Permit` open data
  - [x] Integrates with the [open data resource](https://data.sfgov.org/resource/rqzj-sfat/) using [exsoda](https://hex.pm/packages/exsoda) library
  - [x] Inserts/updates `trucks` based on their `locationid` identifiers
  - [x] Uses [oban](https://hex.pm/packages/oban) to run the asynchronous jobs
- [x] Uses PostGIS exstension to encode the geospatial data from the food trucks in the database
  - [x] Geocodes locations using [geocoder](https://hex.pm/packages/geocoder) library
  - [x] Perform geospatial queries with [geo_postgis](https://hex.pm/packages/geo_postgis) library

## TO-DO
- [ ] Create a page that allows the user to search by address and/or filters, and lists all food trucks matching those conditions, ordered by the closest one, if an address is provided
- [ ] Deploy the application to fly.io

## Architecture overview
### Design choices
### Trade offs
### Future work
* Expose a RESTful API for better integrations
  * Pagination capabilities
  * API keys and rate limiting
* Enhance the geocoding implementation to be fault tolerant in case of provider outages
* Include a map visualization of the food trucks
* Make it social
  * Allow users to rate and review food trucks, mark them as favorites and share them with friends
* Improve on cleaning up food items
  * Aggregate similar food items (rice dishes, rice krispies, rice noodles, rice placet, rice plates, etc)

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
