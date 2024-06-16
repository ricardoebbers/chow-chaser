defmodule ChowChaser.Factory.FoodTrucksFactory do
  @moduledoc false
  alias ChowChaser.FoodTrucks.FoodTruck

  defmacro __using__(_opts) do
    quote do
      alias ChowChaser.FoodTrucks.{FoodItem, FoodTruck}

      def food_item_factory do
        %FoodItem{
          name: sequence(:food_item, &"Food Item #{&1}")
        }
      end

      def food_truck_factory do
        %FoodTruck{
          address: "2450 TARAVAL ST",
          applicant: "Swell Cream & Coffee",
          food_items: build_list(2, :food_item),
          location_description: "TARAVAL ST: 34TH AVE to 35TH AVE (2400 - 2499)",
          location: build(:location),
          object_id: sequence(:object_id, &"#{&1}"),
          status: :approved
        }
      end

      def location_factory do
        %Geo.Point{
          coordinates: {-122.4194, 37.7749},
          srid: 4326
        }
      end
    end
  end
end
