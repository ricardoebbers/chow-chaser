defmodule ChowChaser.Models.Truck do
  @moduledoc """
  The food truck schema.

  This schema represents the trucks table in the database.
  """

  use ChowChaser.Schema

  alias ChowChaser.Models.Item
  alias ChowChaser.Queries.Truck, as: TruckQueries
  alias Ecto.Multi
  alias Geo.PostGIS.Geometry

  @type t :: %__MODULE__{}
  @type changeset :: Ecto.Changeset.t(t())

  @status_values ~w(approved expired issued requested suspend)a
  @required ~w(address applicant location object_id status)a
  @optional ~w(location_description)a
  @location_params ~w(latitude longitude)a

  schema "trucks" do
    field :address, :string
    field :applicant, :string
    field :location_description, :string, default: ""
    field :location, Geometry
    field :object_id, :integer
    field :status, Ecto.Enum, values: @status_values

    field :distance, :float, virtual: true
    field :latitude, :float, virtual: true
    field :longitude, :float, virtual: true

    many_to_many :items, Item,
      join_through: "trucks_items",
      preload_order: [asc: :name],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), map()) :: changeset()
  def changeset(struct, params) do
    params = params |> prepare_status()

    struct
    |> cast(params, @required ++ @optional ++ @location_params, empty_values: [[], nil])
    |> cast_location()
    |> validate_required(@required)
  end

  @spec bulk_upsert_multi(Multi.t(), list(map()), map(), DateTime.t()) :: Multi.t()
  def bulk_upsert_multi(multi, params, object_ids_to_item_names, timestamp) do
    object_ids = Map.keys(object_ids_to_item_names)

    truck_query =
      TruckQueries.new()
      |> TruckQueries.filter_by(%{object_id: object_ids})
      |> TruckQueries.with_items()

    multi
    |> Multi.insert_all(:upsert_trucks, __MODULE__, params,
      placeholders: %{now: timestamp},
      on_conflict: {:replace_all_except, [:id, :object_id]},
      conflict_target: [:object_id]
    )
    |> Multi.all(:trucks, truck_query)
    |> Multi.insert_all(
      :trucks_items,
      "trucks_items",
      fn %{items: items, trucks: trucks} ->
        bulk_upsert_trucks_items(items, trucks, object_ids_to_item_names)
      end,
      on_conflict: :nothing
    )
    |> Multi.all(:trucks_with_items, truck_query)
  end

  defp bulk_upsert_trucks_items(items, trucks, object_ids_to_item_names) do
    items_map = Enum.map(items, &{&1.name, &1.id}) |> Map.new()
    trucks_map = Enum.map(trucks, &{&1.object_id, &1.id}) |> Map.new()

    Enum.flat_map(object_ids_to_item_names, fn {object_id, item_names} ->
      Enum.map(item_names, fn item_name ->
        %{item_id: Map.get(items_map, item_name), truck_id: Map.get(trucks_map, object_id)}
      end)
    end)
  end

  defp prepare_status(params = %{"status" => status}) when is_binary(status) do
    %{params | "status" => String.downcase(status)}
  end

  defp prepare_status(params = %{status: status}) when is_binary(status) do
    %{params | status: String.downcase(status)}
  end

  defp prepare_status(params), do: params

  defp cast_location(changeset) do
    with latitude when is_float(latitude) <- get_change(changeset, :latitude),
         longitude when is_float(longitude) <- get_change(changeset, :longitude) do
      put_change(changeset, :location, point_params(latitude, longitude))
    else
      _ -> changeset
    end
  end

  defp point_params(latitude, longitude) do
    %Geo.Point{coordinates: {longitude, latitude}, srid: 4326}
  end
end
