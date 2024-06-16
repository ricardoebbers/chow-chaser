defmodule ChowChaser.FoodTrucks do
  @moduledoc """
  The FoodTrucks context.
  """

  alias ChowChaser.Models.{Item, Truck}
  alias ChowChaser.Queries.Truck, as: TruckQueries
  alias ChowChaser.Repo
  alias Ecto.Multi

  require Logger

  @spec upsert_all(list(map()) | map()) :: {:ok, list(Truck.t())} | {:error, term()}
  def upsert_all(params) do
    params = Enum.map(params, &Item.prepare_names/1)

    object_ids_to_item_names =
      Enum.map(params, fn params ->
        object_id = get_value(params, :object_id, "") |> to_string() |> String.to_integer()
        items = get_value(params, :items, [])
        {object_id, items}
      end)
      |> Map.new()

    items_names = Map.values(object_ids_to_item_names) |> List.flatten() |> Enum.map(&%{name: &1})

    with {:ok, items_params} <- Item.prepare_bulk_upsert(items_names),
         {:ok, truck_params} <- Truck.prepare_bulk_upsert(params),
         {:ok, %{trucks_with_items: trucks}} <-
           do_upsert_all(items_params, truck_params, object_ids_to_item_names) do
      {:ok, trucks}
    end
  end

  @spec list_all :: list(Truck.t())
  def list_all do
    Repo.all(Truck)
  end

  @spec list_by(map()) :: {:ok, list(Truck.t())} | {:error, term()}
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
    trucks =
      TruckQueries.new()
      |> TruckQueries.filter_by(filters)
      |> TruckQueries.with_distances(filters)
      |> Repo.all()

    {:ok, trucks}
  end

  defp do_upsert_all(items_params, truck_params, object_ids_to_item_names) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Multi.new()
    |> Item.bulk_upsert_multi(items_params, object_ids_to_item_names, now)
    |> Truck.bulk_upsert_multi(truck_params, object_ids_to_item_names, now)
    |> Repo.transaction()
  end

  defp get_value(map, key, default) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key)) || default
  end
end
