defmodule Workers.SyncTrucks do
  @moduledoc """
  A worker that syncs food trucks from the Socrata API.
  """

  use Oban.Worker,
    max_attempts: 3

  @impl Oban.Worker
  def perform(_job) do
    with {:ok, records} <- Socrata.Client.list_all(),
         {:ok, trucks} <- ChowChaser.upsert_all(records) do
      {:ok, trucks}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
