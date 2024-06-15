# ChowChaser
## Screenshots/gifs/videos

## Features
- [ ] List Food Trucks in San Francisco filtered by:
  - [ ] Food trucks near a given location and linear distance from it
  - [ ] Applicant name
  - [ ] Food items sold
  - [ ] Status of the permit (`Approved`, `Expired`, `Issued`, `Requested` or `Suspend` (sic))
- [ ] Periodically synchronizes the internal database with the `Mobile Food Facility Permit` open data
  - [ ] Integrates with the [open data resource](https://data.sfgov.org/resource/rqzj-sfat/) using [exsoda](https://hex.pm/packages/exsoda) library
  - [ ] Uses [oban](https://hex.pm/packages/oban) to run the asynchronous jobs
  - [ ] Inserts/updates `food_trucks` based on their `locationid` identifiers
- [ ] Uses PostGIS exstension to encode the geospatial data from the food trucks in the database
  - [ ] Geocodes locations using [geocoder](https://hex.pm/packages/geocoder) library
  - [ ] Perform geospatial queries with [geo_postgis](https://hex.pm/packages/geo_postgis) library

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
- [ ] Implements an upsert functionality to the food_trucks API
- [ ] Create a worker to list all food trucks from the `Mobile Food Facility Permit` and upsert them in the food_trucks table
- [ ] Configure a cronjob to run that worker once a day
- [ ] Implement converting an address string to a point (longitude/latitude)
- [ ] Create a page that allows the user to search by address and/or filters, and lists all food trucks matching those conditions, ordered by the closest one, if an address is provided
- [x] Use docker-compose to run the project locally
- [ ] Deploy the application to fly.io

## Architecture overview
### Design choices
### Trade offs
### Future work

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
