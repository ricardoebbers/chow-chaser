defmodule ChowChaser.FoodTrucksTest do
  @moduledoc false
  use ChowChaser.DataCase, async: true

  alias ChowChaser.FoodTrucks
  alias ChowChaser.Models.{Item, Truck}

  describe "all/0" do
    test "returns empty list" do
      assert [] == FoodTrucks.all()
    end

    test "lists all food trucks" do
      insert_list(2, :truck)
      assert length(FoodTrucks.all()) == 2
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
        insert(:truck,
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

      {:ok, trucks} = FoodTrucks.list_by(%{reference: address, radius: 400})

      assert [
               %Truck{address: "150 OTIS ST", applicant: "Brazuca Grill", distance: 86.122089},
               %Truck{
                 address: "1800 MISSION ST",
                 applicant: "CARDONA'S FOOD TRUCK",
                 distance: 394.33132991
               }
             ] = trucks
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

    test "filters by items" do
      insert(:truck, items: [build(:item, name: "Burritos")])

      assert {:ok, [%{items: [%{name: "Burritos"}]}]} =
               FoodTrucks.list_by(%{items: "Burritos"})
    end
  end

  describe "upsert_all/1" do
    test "inserts food trucks" do
      trucks = [
        params_for(:truck, applicant: "Brazuca Grill", object_id: 123, status: "REQUESTED")
        |> Map.merge(%{items: "Brazilian", location_description: nil}),
        params_for(:truck, applicant: "CARDONA'S FOOD TRUCK", object_id: 456)
        |> Map.merge(%{items: "Tacos: Burritos", latitude: 30.0, longitude: 40.0})
      ]

      assert {:ok, _} = FoodTrucks.upsert_all(trucks)
    end

    test "upserts existing food trucks based on their object id" do
      %{id: original_id} = insert(:truck, applicant: "Brazuca Grill", object_id: 123)

      trucks = [params_for(:truck, applicant: "Another Grill", object_id: 123, items: [])]

      assert {:ok, [truck]} = FoodTrucks.upsert_all(trucks)

      assert %{id: ^original_id, applicant: "Another Grill", object_id: 123} = truck
    end

    test "creates new food items" do
      trucks = [params_for(:truck) |> Map.put(:items, "Burritos")]

      assert {:ok, [truck]} = FoodTrucks.upsert_all(trucks)

      assert %{items: [%{name: "Burritos"}]} = truck
      assert Repo.aggregate(Item, :count) == 1
    end

    test "associates with existing food items" do
      insert(:item, name: "Burritos")

      trucks = [params_for(:truck) |> Map.put(:items, "Burritos")]

      assert {:ok, [truck]} = FoodTrucks.upsert_all(trucks)

      assert %{items: [%{name: "Burritos"}]} = truck
      assert Repo.aggregate(Item, :count) == 1
    end
  end
end
