defmodule ChowChaser.FoodTrucksTest do
  @moduledoc false
  use ChowChaser.DataCase

  alias ChowChaser.FoodTrucks
  alias ChowChaser.FoodTrucks.FoodTruck

  describe "all/0" do
    test "returns empty list" do
      assert [] == FoodTrucks.all()
    end

    test "lists all food trucks" do
      insert_list(2, :food_truck)
      food_trucks = FoodTrucks.all()

      assert length(food_trucks) == 2
    end
  end

  describe "list_by/1" do
    setup do
      [
        {"Brazuca Grill", "150 OTIS ST", {-122.42087956139908, 37.770683395042624}, :expired},
        {"CARDONA'S FOOD TRUCK", "1800 MISSION ST", {-122.42057533514163, 37.767817181414145},
         :approved},
        {"CARDONA'S FOOD TRUCK", "1888 MISSION ST", {-122.42032247306807, 37.766897602559155},
         :approved},
        {"Brazuca Grill", "1750 FOLSOM ST", {-122.41598117460148, 37.76890352056648}, :approved}
      ]
      |> Enum.map(fn {applicant, address, coordinates, status} ->
        insert(:food_truck,
          applicant: applicant,
          address: address,
          location: build(:location, coordinates: coordinates),
          status: status
        )
      end)

      :ok
    end

    test "filters by address and radius" do
      address = "150 OTIS ST"

      {:ok, food_trucks} = FoodTrucks.list_by(%{reference: address, radius: 400})

      assert [
               %FoodTruck{
                 address: "150 OTIS ST",
                 applicant: "Brazuca Grill",
                 distance: 86.122089
               },
               %FoodTruck{
                 address: "1800 MISSION ST",
                 applicant: "CARDONA'S FOOD TRUCK",
                 distance: 394.33132991
               }
             ] = food_trucks
    end

    test "filters by status" do
      assert {:ok, [%{status: :expired}]} = FoodTrucks.list_by(%{status: "expired"})
    end

    test "filters by address" do
      assert {:ok, [%{address: "150 OTIS ST"}]} = FoodTrucks.list_by(%{address: "150 OTIS ST"})
    end

    test "filters by applicant" do
      assert {:ok, [%{applicant: "Brazuca Grill"}, %{applicant: "Brazuca Grill"}]} =
               FoodTrucks.list_by(%{applicant: "Brazuca Grill"})
    end

    test "filters by food types" do
      insert(:food_truck, food_items: [build(:food_item, name: "Burritos")])

      assert {:ok, [%{food_items: [%{name: "Burritos"}]}]} =
               FoodTrucks.list_by(%{food_types: "Burritos"})
    end
  end
end
