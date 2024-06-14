defmodule ChowChaserWeb.FoodTruckLive.Index do
  use ChowChaserWeb, :live_view

  alias ChowChaser.FoodTrucks
  alias ChowChaser.FoodTrucks.FoodTruck

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :food_trucks, FoodTrucks.list_food_trucks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Food truck")
    |> assign(:food_truck, FoodTrucks.get_food_truck!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Food truck")
    |> assign(:food_truck, %FoodTruck{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Food trucks")
    |> assign(:food_truck, nil)
  end

  @impl true
  def handle_info({ChowChaserWeb.FoodTruckLive.FormComponent, {:saved, food_truck}}, socket) do
    {:noreply, stream_insert(socket, :food_trucks, food_truck)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    food_truck = FoodTrucks.get_food_truck!(id)
    {:ok, _} = FoodTrucks.delete_food_truck(food_truck)

    {:noreply, stream_delete(socket, :food_trucks, food_truck)}
  end
end
