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

  @food_items_separator ":"

  schema "food_items" do
    field :name, :string

    many_to_many :food_trucks, FoodTruck,
      join_through: "food_trucks_items",
      preload_order: [asc: :applicant],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @spec create_changeset(params()) :: Ecto.Changeset.t(t())
  def create_changeset(attrs), do: changeset(%__MODULE__{}, attrs)

  defp changeset(food_item, attrs) do
    food_item
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  @spec prepare_names(map()) :: list(t())
  def prepare_names(params = %{food_items: food_items}) do
    %{params | food_items: cleanup_names(food_items)}
  end

  def prepare_names(params = %{"food_items" => food_items}) do
    %{params | "food_items" => cleanup_names(food_items)}
  end

  def prepare_names(params), do: params

  defp cleanup_names(names) do
    cleanup_fun = &String.split(String.capitalize(to_string(&1)), @food_items_separator)

    names
    |> List.wrap()
    |> Enum.flat_map(cleanup_fun)
    |> Enum.map(&String.trim(&1))
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end
end
