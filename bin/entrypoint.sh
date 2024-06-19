#!/bin/bash
mix deps.get
mix ecto.setup
mix one_offs.sync_trucks
exec iex -S mix phx.server
