defmodule ChowChaser.FoodTrucks.FoodTruck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_trucks" do
    field :status, :string
    field :address, :string
    field :location_id, :integer
    field :applicant, :string
    field :facility_type, :string
    field :location_description, :string
    field :food_items, :string
    field :latitude, :string
    field :longitude, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(food_truck, attrs) do
    food_truck
    |> cast(attrs, [
      :location_id,
      :applicant,
      :facility_type,
      :location_description,
      :address,
      :status,
      :food_items,
      :latitude,
      :longitude
    ])
    |> validate_required([
      :location_id,
      :applicant,
      :facility_type,
      :location_description,
      :address,
      :status,
      :food_items,
      :latitude,
      :longitude
    ])
  end
end
