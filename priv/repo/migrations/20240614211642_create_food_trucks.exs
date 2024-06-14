defmodule ChowChaser.Repo.Migrations.CreateFoodTrucks do
  use Ecto.Migration

  def change do
    create table(:food_trucks) do
      add :location_id, :integer
      add :applicant, :string
      add :facility_type, :string
      add :location_description, :string
      add :address, :string
      add :status, :string
      add :food_items, :string
      add :latitude, :string
      add :longitude, :string

      timestamps(type: :utc_datetime)
    end
  end
end
