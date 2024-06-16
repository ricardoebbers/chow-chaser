import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :chow_chaser, ChowChaser.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "chow_chaser_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chow_chaser, ChowChaserWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Mmr8JpwICYVGlDS+SLh4z0W076KKvR5e7fJMF71N6GhBOisUhgrJbdiQQfyPB9Nz",
  server: false

# In test we don't send emails.
config :chow_chaser, ChowChaser.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

config :geocoder, :worker, provider: Geocoder.Providers.Fake

config :geocoder, Geocoder.Worker,
  data: %{
    ~r/.*150 OTIS ST.*/ => %{
      lat: 37.7713678,
      lon: -122.420419,
      bounds: %{
        top: 37.7713178,
        right: -122.420369,
        bottom: 37.7714178,
        left: -122.420469
      },
      location: %{
        city: "San Francisco",
        state: "California",
        county: "Mission District",
        country: "United States",
        postal_code: "94103",
        street: "Otis Street",
        street_number: nil,
        country_code: "us",
        formatted_address:
          "150 Otis Street, Otis Street, Hayes Valley, Mission District, San Francisco, California, 94103, United States"
      }
    }
  }
