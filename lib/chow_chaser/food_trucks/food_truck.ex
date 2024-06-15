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
          object_id: integer(),
          status: atom() | String.t(),
          location_description: String.t(),
          location: Geo.Point.t(),
          food_items: list(FoodItem.t()),
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

  @fields ~w(address applicant location_description location object_id status)a

  schema "food_trucks" do
    field :address, :string
    field :applicant, :string
    field :location_description, :string
    field :location, Geometry
    field :object_id, :integer
    field :status, Ecto.Enum, values: @status_values

    many_to_many :food_items, FoodItem, join_through: "food_trucks_items"

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), params()) :: Ecto.Changeset.t(t())
  def changeset(food_truck, params) do
    params = prepare_location(params)

    food_truck
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> cast_assoc(:food_items)
  end

  defp prepare_location(params = %{"latitude" => latitude, "longitude" => longitude}) do
    Map.put(params, "location", point_params(latitude, longitude))
  end

  defp prepare_location(params = %{latitude: latitude, longitude: longitude}) do
    Map.put(params, :location, point_params(latitude, longitude))
  end

  defp prepare_location(params), do: params

  defp point_params(latitude, longitude) do
    %Geo.Point{coordinates: {longitude, latitude}, srid: 4326}
  end
end
