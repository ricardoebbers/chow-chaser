defmodule ChowChaser.Repo.Migrations.CreateFoodItemsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table("food_items") do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists table("food_trucks_items") do
      add :food_truck_id, references("food_trucks", on_delete: :delete_all), null: false
      add :food_item_id, references("food_items", on_delete: :delete_all), null: false
    end

    # Unique index to make sure we don't have duplicate food items in a food truck
    create_if_not_exists unique_index("food_trucks_items", [:food_truck_id, :food_item_id])
  end
end
