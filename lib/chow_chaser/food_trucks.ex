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
        object_id = get_value(params, :object_id, 0) |> to_string() |> String.to_integer()
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
    TruckQueries.new()
    |> TruckQueries.with_items()
    |> Repo.all()
  end

  @spec list_by(map()) :: list(Truck.t())
  def list_by(filters = %{"reference" => reference}) do
    filters = to_atom_map(filters)

    case Geocoder.call(reference) do
      {:ok, %Geocoder.Coords{lat: latitude, lon: longitude}} ->
        filters
        |> Map.put(:coordinates, {longitude, latitude})
        |> Map.put(:radius, Map.get(filters, :radius, 1000))
        |> do_list_by()

      {:error, nil} ->
        # falls back to searching by the address or location description
        filters
        |> Map.delete(:reference)
        |> Map.put(:address, reference)
        |> do_list_by()
    end
  end

  def list_by(filters) do
    filters
    |> to_atom_map()
    |> do_list_by()
  end

  def search_params do
    Truck.changeset(%Truck{}, %{})
  end

  defp do_list_by(filters) do
    TruckQueries.new()
    |> TruckQueries.filter_by(filters)
    |> TruckQueries.with_distances(filters)
    |> TruckQueries.with_items()
    |> Repo.all()
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

  defp to_atom_map(map) do
    Map.new(map, fn
      {k, v} when is_binary(k) -> {String.to_atom(k), v}
      {k, v} -> {k, v}
    end)
  end
end
