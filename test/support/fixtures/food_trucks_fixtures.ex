defmodule ChowChaser.FoodTrucksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChowChaser.FoodTrucks` context.
  """

  @doc """
  Generate a food_truck.
  """
  def food_truck_fixture(attrs \\ %{}) do
    {:ok, food_truck} =
      attrs
      |> Enum.into(%{
        address: "some address",
        applicant: "some applicant",
        facility_type: "some facility_type",
        food_items: "some food_items",
        latitude: "some latitude",
        location_description: "some location_description",
        location_id: 42,
        longitude: "some longitude",
        status: "some status"
      })
      |> ChowChaser.FoodTrucks.create_food_truck()

    food_truck
  end
end
