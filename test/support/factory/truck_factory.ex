defmodule ChowChaser.Factory.TruckFactory do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      alias ChowChaser.Models.Truck

      def truck_factory do
        %Truck{
          address: "2450 TARAVAL ST",
          applicant: "Swell Cream & Coffee",
          items: build_list(2, :item),
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
