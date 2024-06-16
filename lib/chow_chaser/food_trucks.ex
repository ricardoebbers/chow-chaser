defmodule ChowChaser.FoodTrucks do
  @moduledoc """
  The FoodTrucks context.
  """

  alias ChowChaser.FoodTrucks.FoodTruck
  alias ChowChaser.FoodTrucks.Queries
  alias ChowChaser.Repo

  require Logger

  @doc """
  Returns all food trucks.

  ## Examples

      iex> all()
      [%FoodTruck{}, ...]

  """
  @spec all :: list(FoodTruck.t())
  def all do
    Repo.all(FoodTruck)
  end

  @spec list_by(map()) :: {:ok, list(FoodTruck.t())} | {:error, term()}
  def list_by(filters = %{reference: reference}) do
    case Geocoder.call(reference) do
      {:ok, %Geocoder.Coords{lat: latitude, lon: longitude}} ->
        filters =
          filters
          |> Map.put(:coordinates, {longitude, latitude})
          |> Map.put(:radius, Map.get(filters, :radius, 500))

        do_list_by(filters)

      {:error, nil} ->
        {:error, "Invalid address"}
    end
  end

  def list_by(filters), do: do_list_by(filters)

  defp do_list_by(filters) do
    food_trucks =
      Queries.from_food_truck()
      |> Queries.filter_by(filters)
      |> Queries.with_distances(filters)
      |> Repo.all()

    {:ok, food_trucks}
  end
end
