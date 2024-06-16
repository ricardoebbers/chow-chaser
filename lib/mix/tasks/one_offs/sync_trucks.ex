defmodule Mix.Tasks.OneOffs.SyncTrucks do
  @moduledoc """
  This task is intended to be used in development to sync the trucks when setting up the project.

  Usage:
    mix one_offs.sync_trucks
  """
  @shortdoc "Triggers a Sync Truck worker job"
  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    Workers.SyncTrucks.perform(%{})
  end
end
