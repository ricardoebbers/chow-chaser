defmodule ChowChaser.Queries.Truck do
  @moduledoc """
  Queries for the  aggregate.
  """

  alias ChowChaser.Models.Truck

  import Ecto.Query
  import Geo.PostGIS

  @type queryable :: Truck | Ecto.Query.t()

  @spec new :: queryable()
  def new do
    from(Truck, as: :truck)
  end

  @spec filter_by(queryable(), map()) :: queryable()
  def filter_by(queryable, filters = %{coordinates: coordinates, radius: radius}) do
    point = %Geo.Point{coordinates: coordinates, srid: 4326}

    queryable
    |> where([truck: t], st_dwithin_in_meters(t.location, ^point, ^radius))
    |> filter_by(Map.drop(filters, [:coordinates, :radius]))
  end

  def filter_by(queryable, filters = %{items: items}) do
    items = List.wrap(items)

    queryable
    |> join(:inner, [truck: t], items in assoc(t, :items), as: :item)
    |> where([truck: t, item: i], i.name in ^items)
    |> preload(:items)
    |> filter_by(Map.drop(filters, [:items]))
  end

  def filter_by(queryable, filters = %{location_description: location_description}) do
    queryable
    |> where([truck: t], ilike(t.location_description, ^"%#{location_description}%"))
    |> filter_by(Map.drop(filters, [:location_description]))
  end

  def filter_by(queryable, filters = %{address: address}) do
    queryable
    |> where([truck: t], ilike(t.address, ^"%#{address}%"))
    |> filter_by(Map.drop(filters, [:address]))
  end

  def filter_by(queryable, filters) do
    valid_filters = Truck.__schema__(:fields)

    filters =
      filters
      |> Map.take(valid_filters)
      |> Enum.reject(fn {_, value} -> is_nil(value) end)
      |> Keyword.new()

    Enum.reduce(filters, queryable, fn
      {field, value}, queryable when is_list(value) ->
        where(queryable, [truck: t], field(t, ^field) in ^value)

      {field, value}, queryable ->
        where(queryable, [truck: t], field(t, ^field) == ^value)
    end)
  end

  @spec with_distances(queryable(), map()) :: queryable()
  def with_distances(queryable, %{coordinates: coordinates}) do
    point = %Geo.Point{coordinates: coordinates, srid: 4326}

    queryable
    |> select([truck: t], %{t | distance: st_distance_in_meters(t.location, ^point)})
    |> order_by([truck: t], asc: st_distance_in_meters(t.location, ^point))
  end

  def with_distances(queryable, _), do: queryable

  @spec with_items(queryable()) :: queryable()
  def with_items(queryable) do
    preload(queryable, :items)
  end
end
