defmodule ChowChaser.FoodTrucks.FoodItem do
  @moduledoc """
  The FoodItem schema.

  This schema represents the food_items table in the database.
  """

  use Ecto.Schema

  alias ChowChaser.FoodTrucks.FoodTruck
  alias ChowChaser.Repo

  import Ecto.Changeset
  import Ecto.Query

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

  @food_items_separator ":"

  schema "food_items" do
    field :name, :string

    many_to_many :food_trucks, FoodTruck,
      join_through: "food_trucks_items",
      preload_order: [asc: :applicant],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), params()) :: Ecto.Changeset.t(t())
  def changeset(food_item, attrs) do
    food_item
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  @spec upsert_all(map()) :: list(t())
  def upsert_all(params) do
    names =
      (Map.get(params, "food_items") || Map.get(params, :food_items) || [])
      |> List.wrap()
      |> Enum.flat_map(&String.split(to_string(&1), @food_items_separator, trim: true))
      |> Enum.map(&String.trim(&1))
      |> Enum.reject(&(&1 == ""))
      |> Enum.uniq()

    food_items =
      Enum.map(
        names,
        &%{name: &1, inserted_at: {:placeholder, :now}, updated_at: {:placeholder, :now}}
      )

    Repo.insert_all(
      __MODULE__,
      food_items,
      placeholders: %{now: DateTime.utc_now() |> DateTime.truncate(:second)},
      on_conflict: :nothing,
      returning: true
    )

    Repo.all(from(fi in __MODULE__, where: fi.name in ^names))
  end
end
