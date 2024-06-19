# ChowChaser
## Introduction
ChowChaser is a Phoenix-based web application designed to help food enthusiasts locate food trucks in San Francisco. It leverages geospatial data to provide users with an easy way to find food trucks near a given location, synchronized with the most recent city's open data on food trucks.

## Showcase
https://github.com/ricardoebbers/chow-chaser/assets/20364528/9b9af526-543c-4de4-b210-1705788a334a

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
### Docker setup
#### Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Ports 4000 and 5432 available

#### Running the application

Use `docker-compose` to start the server locally:
```bash
docker-compose up -d
```
Visit the page in http://localhost:4000

### Local setup
#### Requirements
##### Postgres with PostGIS extension
- [Postgres](https://www.postgresql.org/download/)
- [PostGIS](https://postgis.net/documentation/getting_started/#installing-postgis)

##### Elixir/Erlang
I recommend using asdf to manage your Elixir and Erlang versions. You can find instructions on how to install asdf [here](https://asdf-vm.com/#/core-manage-asdf-vm).

Otherwise, you can install Elixir and Erlang manually:
- [Elixir](https://elixir-lang.org/install.html)
- [Erlang](https://www.erlang.org/downloads)

##### Phoenix Framework
- [Phoenix](https://hexdocs.pm/phoenix/installation.html)

##### Setup the environment
Fetch and compile the dependencies:
```bash
mix deps.get
mix deps.compile
```

Run the following commands to create the database, run the migrations and build the assets:
```bash
mix ecto.setup
```

Run the one-off task to synchronize the food trucks
```bash
mix one_offs.sync_trucks
```

#### Running the application

Start the Phoenix server:
```bash
iex -S mix.phx.server
```

Visit the page in http://localhost:4000
