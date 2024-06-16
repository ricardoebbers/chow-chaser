defmodule ChowChaser.Repo.Migrations.CreateFoodItemsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table("food_items") do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists unique_index("food_items", [:name])

    create_if_not_exists table("food_trucks_items", primary_key: false) do
      add :food_truck_id, references("food_trucks", on_delete: :delete_all),
        null: false,
        primary_key: true

      add :food_item_id, references("food_items", on_delete: :delete_all),
        null: false,
        primary_key: true
    end
  end
end
