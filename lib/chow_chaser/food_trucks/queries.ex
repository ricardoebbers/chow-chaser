defmodule ChowChaser.FoodTrucks.Queries do
  @moduledoc """
  Queries for the FoodTrucks aggregate.
  """
  alias ChowChaser.FoodTrucks.FoodTruck
  import Ecto.Query
  import Geo.PostGIS

  @type queryable :: FoodTruck | Ecto.Query.t()

  @spec from_food_truck :: queryable()
  def from_food_truck do
    from(FoodTruck, as: :food_truck)
  end

  @spec filter_by(queryable(), map()) :: queryable()
  def filter_by(queryable, filters = %{coordinates: coordinates, radius: radius}) do
    point = %Geo.Point{coordinates: coordinates, srid: 4326}

    queryable
    |> where([food_truck: food_truck], st_dwithin_in_meters(food_truck.location, ^point, ^radius))
    |> filter_by(Map.drop(filters, [:coordinates, :radius]))
  end

  def filter_by(queryable, filters = %{food_types: food_types}) do
    food_types = List.wrap(food_types)

    queryable
    |> join(:inner, [food_truck: food_truck], food_items in assoc(food_truck, :food_items),
      as: :food_item
    )
    |> where(
      [food_truck: food_truck, food_item: food_item],
      food_item.name in ^food_types
    )
    |> preload(:food_items)
    |> filter_by(Map.drop(filters, [:food_types]))
  end

  def filter_by(queryable, filters) do
    valid_filters = FoodTruck.__schema__(:fields)

    filters =
      filters
      |> Map.take(valid_filters)
      |> Enum.reject(fn {_, value} -> value == nil end)
      |> Keyword.new()

    queryable
    |> where([food_truck: food_truck], ^filters)
  end

  @spec with_distances(queryable(), map()) :: queryable()
  def with_distances(queryable, %{coordinates: coordinates}) do
    point = %Geo.Point{coordinates: coordinates, srid: 4326}

    queryable
    |> select(
      [food_truck: food_truck],
      %{food_truck | distance: st_distance_in_meters(food_truck.location, ^point)}
    )
    |> order_by([food_truck: food_truck], asc: st_distance_in_meters(food_truck.location, ^point))
  end

  def with_distances(queryable, _), do: queryable
end
