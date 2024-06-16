defmodule ChowChaserWeb.FoodTruckLive.Index do
  use ChowChaserWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :food_trucks, ChowChaser.list_all())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Food trucks in San Francisco")
  end
end
