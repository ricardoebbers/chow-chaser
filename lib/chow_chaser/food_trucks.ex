defmodule ChowChaser.FoodTrucks do
  @moduledoc """
  The FoodTrucks context.
  """

  alias ChowChaser.FoodTrucks.{FoodTruck, Queries}
  alias ChowChaser.Repo
  alias Ecto.Multi

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

  @spec upsert_all(list(FoodTruck.params()) | FoodTruck.params()) ::
          {:ok, list(FoodTruck.t())} | {:error, term()}
  def upsert_all(food_trucks) do
    result =
      food_trucks
      |> List.wrap()
      |> Enum.with_index()
      |> Enum.reduce(Multi.new(), fn {food_truck, index}, multi ->
        Multi.insert(multi, "food_truck_#{index}", FoodTruck.create_changeset(food_truck),
          on_conflict: {:replace_all_except, [:id, :object_id]},
          conflict_target: [:object_id]
        )
      end)
      |> Repo.transaction()

    case result do
      {:ok, food_trucks} -> {:ok, Map.values(food_trucks)}
      {:error, _failed_op, _reason, _changes} -> {:error, "Failed to insert food trucks"}
    end
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
