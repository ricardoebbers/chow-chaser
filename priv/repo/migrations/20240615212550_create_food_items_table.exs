defmodule ChowChaser.Repo.Migrations.CreateFoodItemsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table("items") do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists unique_index("items", [:name])

    create_if_not_exists table("trucks_items", primary_key: false) do
      add :truck_id, references("trucks", on_delete: :delete_all),
        null: false,
        primary_key: true

      add :item_id, references("items", on_delete: :delete_all),
        null: false,
        primary_key: true
    end
  end
end
