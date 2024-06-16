defmodule Socrata.Client do
  @moduledoc """
  A client for the Socrata API.
  """

  alias Socrata.Record
  import Exsoda.Reader

  @resource "rqzj-sfat"
  @domain "data.sfgov.org"

  @spec list_all :: {:ok, list(Record.t())} | {:error, term()}
  def list_all do
    with {:ok, stream} <- query(@resource, domain: @domain) |> select(Record.fields()) |> run() do
      {:ok, Enum.map(stream, fn row -> Record.new(row) |> Record.to_params() end)}
    end
  end
end
