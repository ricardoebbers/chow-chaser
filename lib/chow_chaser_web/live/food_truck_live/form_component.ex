defmodule ChowChaserWeb.FoodTruckLive.FormComponent do
  use ChowChaserWeb, :live_component

  alias ChowChaser.FoodTrucks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage food_truck records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="food_truck-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:location_id]} type="number" label="Location" />
        <.input field={@form[:applicant]} type="text" label="Applicant" />
        <.input field={@form[:facility_type]} type="text" label="Facility type" />
        <.input field={@form[:location_description]} type="text" label="Location description" />
        <.input field={@form[:address]} type="text" label="Address" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:food_items]} type="text" label="Food items" />
        <.input field={@form[:latitude]} type="text" label="Latitude" />
        <.input field={@form[:longitude]} type="text" label="Longitude" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Food truck</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{food_truck: food_truck} = assigns, socket) do
    changeset = FoodTrucks.change_food_truck(food_truck)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"food_truck" => food_truck_params}, socket) do
    changeset =
      socket.assigns.food_truck
      |> FoodTrucks.change_food_truck(food_truck_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"food_truck" => food_truck_params}, socket) do
    save_food_truck(socket, socket.assigns.action, food_truck_params)
  end

  defp save_food_truck(socket, :edit, food_truck_params) do
    case FoodTrucks.update_food_truck(socket.assigns.food_truck, food_truck_params) do
      {:ok, food_truck} ->
        notify_parent({:saved, food_truck})

        {:noreply,
         socket
         |> put_flash(:info, "Food truck updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_food_truck(socket, :new, food_truck_params) do
    case FoodTrucks.create_food_truck(food_truck_params) do
      {:ok, food_truck} ->
        notify_parent({:saved, food_truck})

        {:noreply,
         socket
         |> put_flash(:info, "Food truck created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
