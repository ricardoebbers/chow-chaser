defmodule ChowChaser.Repo.Migrations.CreateFoodTrucksTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table("trucks") do
      add :address, :string, null: false
      add :applicant, :string, null: false
      add :location_description, :string, null: false
      add :object_id, :integer, null: false
      add :status, :string, null: false

      timestamps(type: :utc_datetime)
    end

    # Add a field `location` with type `geometry(Point,4326)` to the "trucks" table.
    # This can store a "standard GPS" (epsg4326) coordinate pair {longitude,latitude}.
    execute("SELECT AddGeometryColumn('trucks','location',4326,'POINT',2);")

    # Index to speed up spatial searches of the data
    create_if_not_exists index("trucks", [:location], using: :gist)

    # Unique index to make sure we don't have duplicate food trucks
    create_if_not_exists unique_index("trucks", [:object_id])
  end
end
