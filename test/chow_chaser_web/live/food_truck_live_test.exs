defmodule ChowChaserWeb.FoodTruckLiveTest do
  @moduledoc false
  use ChowChaserWeb.ConnCase, async: true

  describe "index" do
    setup do
      insert_list(2, :truck)
      :ok
    end

    test "lists all trucks", %{conn: _conn} do
      flunk("To be implemented")
    end
  end
end
