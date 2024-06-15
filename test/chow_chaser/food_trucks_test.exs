defmodule ChowChaser.FoodTrucksTest do
  @moduledoc false
  use ChowChaser.DataCase

  alias ChowChaser.FoodTrucks

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
end
