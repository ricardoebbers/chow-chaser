# ChowChaser
## Screenshots/gifs/videos

## Features
- [x] List Food Trucks in San Francisco filtered by:
  - [x] Food trucks near a given location and linear distance from it
  - [x] Applicant name
  - [x] Food items sold
  - [x] Status of the permit (`Approved`, `Expired`, `Issued`, `Requested` or `Suspend` (sic))
- [ ] Periodically synchronizes the internal database with the `Mobile Food Facility Permit` open data
  - [x] Integrates with the [open data resource](https://data.sfgov.org/resource/rqzj-sfat/) using [exsoda](https://hex.pm/packages/exsoda) library
  - [x] Inserts/updates `food_trucks` based on their `locationid` identifiers
  - [ ] Uses [oban](https://hex.pm/packages/oban) to run the asynchronous jobs
- [x] Uses PostGIS exstension to encode the geospatial data from the food trucks in the database
  - [x] Geocodes locations using [geocoder](https://hex.pm/packages/geocoder) library
  - [x] Perform geospatial queries with [geo_postgis](https://hex.pm/packages/geo_postgis) library

## TO-DO checklist
- [x] Generate a Phoenix Live view application
- [x] Add `geo_postgis` to the project
- [x] Add `exsoda` to the project
- [x] Add `oban` to the project
- [x] Add `geocoder` to the project
- [x] Add `credo` to the project
- [x] Add `exmachina` to the project
- [x] Create a `food_trucks` table, with a `geom` field that encodes the longitude/latitude
- [x] Create a `food_items` table to hold all food items options
- [x] Create a `trucks_items` relationship between the two tables
- [x] Implement converting an address string to a point (longitude/latitude)
- [x] Implement an upsert functionality to the food_trucks API
- [x] Use docker-compose to run the project locally
- [ ] Create a worker to list all food trucks from the `Mobile Food Facility Permit` and upsert them in the food_trucks table
- [ ] Configure a cronjob to run that worker once a day
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

## Setting up

### Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Ports 4000 and 5432 available

### Running the server

Use `docker-compose` to start the server locally:
```bash
docker-compose up
```
Visit the page in http://localhost:4000
