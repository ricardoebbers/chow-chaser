defmodule ChowChaser.FoodTrucksTest do
  use ChowChaser.DataCase

  alias ChowChaser.FoodTrucks

  describe "food_trucks" do
    alias ChowChaser.FoodTrucks.FoodTruck

    import ChowChaser.FoodTrucksFixtures

    @invalid_attrs %{status: nil, address: nil, location_id: nil, applicant: nil, facility_type: nil, location_description: nil, food_items: nil, latitude: nil, longitude: nil}

    test "list_food_trucks/0 returns all food_trucks" do
      food_truck = food_truck_fixture()
      assert FoodTrucks.list_food_trucks() == [food_truck]
    end

    test "get_food_truck!/1 returns the food_truck with given id" do
      food_truck = food_truck_fixture()
      assert FoodTrucks.get_food_truck!(food_truck.id) == food_truck
    end

    test "create_food_truck/1 with valid data creates a food_truck" do
      valid_attrs = %{status: "some status", address: "some address", location_id: 42, applicant: "some applicant", facility_type: "some facility_type", location_description: "some location_description", food_items: "some food_items", latitude: "some latitude", longitude: "some longitude"}

      assert {:ok, %FoodTruck{} = food_truck} = FoodTrucks.create_food_truck(valid_attrs)
      assert food_truck.status == "some status"
      assert food_truck.address == "some address"
      assert food_truck.location_id == 42
      assert food_truck.applicant == "some applicant"
      assert food_truck.facility_type == "some facility_type"
      assert food_truck.location_description == "some location_description"
      assert food_truck.food_items == "some food_items"
      assert food_truck.latitude == "some latitude"
      assert food_truck.longitude == "some longitude"
    end

    test "create_food_truck/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FoodTrucks.create_food_truck(@invalid_attrs)
    end

    test "update_food_truck/2 with valid data updates the food_truck" do
      food_truck = food_truck_fixture()
      update_attrs = %{status: "some updated status", address: "some updated address", location_id: 43, applicant: "some updated applicant", facility_type: "some updated facility_type", location_description: "some updated location_description", food_items: "some updated food_items", latitude: "some updated latitude", longitude: "some updated longitude"}

      assert {:ok, %FoodTruck{} = food_truck} = FoodTrucks.update_food_truck(food_truck, update_attrs)
      assert food_truck.status == "some updated status"
      assert food_truck.address == "some updated address"
      assert food_truck.location_id == 43
      assert food_truck.applicant == "some updated applicant"
      assert food_truck.facility_type == "some updated facility_type"
      assert food_truck.location_description == "some updated location_description"
      assert food_truck.food_items == "some updated food_items"
      assert food_truck.latitude == "some updated latitude"
      assert food_truck.longitude == "some updated longitude"
    end

    test "update_food_truck/2 with invalid data returns error changeset" do
      food_truck = food_truck_fixture()
      assert {:error, %Ecto.Changeset{}} = FoodTrucks.update_food_truck(food_truck, @invalid_attrs)
      assert food_truck == FoodTrucks.get_food_truck!(food_truck.id)
    end

    test "delete_food_truck/1 deletes the food_truck" do
      food_truck = food_truck_fixture()
      assert {:ok, %FoodTruck{}} = FoodTrucks.delete_food_truck(food_truck)
      assert_raise Ecto.NoResultsError, fn -> FoodTrucks.get_food_truck!(food_truck.id) end
    end

    test "change_food_truck/1 returns a food_truck changeset" do
      food_truck = food_truck_fixture()
      assert %Ecto.Changeset{} = FoodTrucks.change_food_truck(food_truck)
    end
  end
end
