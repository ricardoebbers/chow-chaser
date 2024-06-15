defmodule ChowChaser.FoodTrucks.FoodItem do
  @moduledoc """
  The FoodItem schema.

  This schema represents the food_items table in the database.
  """

  use Ecto.Schema
  alias ChowChaser.FoodTrucks.FoodTruck
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          food_trucks: list(FoodTruck.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @type params :: %{
          name: String.t()
        }

  schema "food_items" do
    field :name, :string
    many_to_many :food_trucks, FoodTruck, join_through: "food_trucks_items"

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), params()) :: Ecto.Changeset.t(t())
  def changeset(food_item \\ %__MODULE__{}, attrs \\ %{}) do
    food_item
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
