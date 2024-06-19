defmodule ChowChaserWeb.FoodTruckLive.Index do
  use ChowChaserWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:form, to_form(ChowChaser.search_params()))
     |> stream(:food_trucks, ChowChaser.list_all())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"truck" => params}, socket) do
    params =
      params
      |> Map.merge(%{
        "reference" => "#{params["reference"]}, San Francisco",
        "status" => "approved"
      })

    {:noreply,
     socket
     |> stream(:food_trucks, ChowChaser.list_by(params), reset: true)}
  end
end
