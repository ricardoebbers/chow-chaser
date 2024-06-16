defmodule ChowChaser.FoodTrucks.FoodTruck do
  @moduledoc """
  The FoodTruck schema.

  This schema represents the food_trucks table in the database.
  """

  use Ecto.Schema

  alias ChowChaser.FoodTrucks.FoodItem
  alias Geo.PostGIS.Geometry

  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          address: String.t(),
          applicant: String.t(),
          food_items: list(FoodItem.t()),
          location_description: String.t(),
          location: Geo.Point.t(),
          object_id: integer(),
          status: atom() | String.t(),
          distance: float() | nil,
          latitude: float() | nil,
          longitude: float() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @type params :: %{
          address: String.t(),
          applicant: String.t(),
          food_items: list(FoodItem.params()),
          latitude: String.t(),
          location_description: String.t(),
          longitude: String.t(),
          object_id: String.t(),
          status: String.t()
        }

  @status_values ~w(approved expired issued requested suspend)a
  @required ~w(address applicant location object_id status)a
  @optional ~w(location_description)a
  @location_params ~w(latitude longitude)a

  schema "food_trucks" do
    field :address, :string
    field :applicant, :string
    field :location_description, :string, default: ""
    field :location, Geometry
    field :object_id, :integer
    field :status, Ecto.Enum, values: @status_values

    field :distance, :float, virtual: true
    field :latitude, :float, virtual: true
    field :longitude, :float, virtual: true

    many_to_many :food_items, FoodItem,
      join_through: "food_trucks_items",
      preload_order: [asc: :name],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @spec create_changeset(params()) :: Ecto.Changeset.t(t())
  def create_changeset(params), do: changeset(%__MODULE__{}, params)

  defp changeset(food_truck, params) do
    params = params |> prepare_status()

    food_truck
    |> cast(params, @required ++ @optional ++ @location_params, empty_values: [[], nil])
    |> cast_location()
    |> validate_required(@required)
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
