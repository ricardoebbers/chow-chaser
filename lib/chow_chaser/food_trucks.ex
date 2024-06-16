defmodule ChowChaser.FoodTrucks do
  @moduledoc """
  The FoodTrucks context.
  """

  alias ChowChaser.FoodTrucks.{FoodItem, FoodTruck, Queries}
  alias ChowChaser.Repo
  alias Ecto.Multi

  import Ecto.Query

  require Logger

  @doc """
  Returns all food trucks.

  ## Examples

      iex> all()
      [%FoodTruck{}, ...]

  """
  @spec all :: list(FoodTruck.t())
  def all do
    Repo.all(FoodTruck)
  end

  @spec upsert_all(list(FoodTruck.params()) | FoodTruck.params()) ::
          {:ok, list(FoodTruck.t())} | {:error, term()}
  # def upsert_all(food_trucks) do
  #   result =
  #     food_trucks
  #     |> List.wrap()
  #     |> Enum.with_index()
  #     |> Enum.reduce(Multi.new(), fn {food_truck, index}, multi ->
  #       Multi.insert(multi, "food_truck_#{index}", FoodTruck.create_changeset(food_truck),
  #         on_conflict: {:replace_all_except, [:id, :object_id]},
  #         conflict_target: [:object_id]
  #       )
  #     end)
  #     |> Repo.transaction()

  #   case result do
  #     {:ok, food_trucks} -> {:ok, Map.values(food_trucks)}
  #     {:error, _failed_op, _reason, _changes} -> {:error, "Failed to insert food trucks"}
  #   end
  # end

  def upsert_all(params) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    params = Enum.map(params, &FoodItem.prepare_names/1)

    items_names =
      Enum.flat_map(params, &(Map.get(&1, "food_items") || Map.get(&1, :food_items) || []))

    object_ids =
      Enum.map(params, &(Map.get(&1, "object_id") || Map.get(&1, :object_id) || []))

    result =
      Multi.new()
      |> Multi.insert_all(
        :upsert_food_items,
        FoodItem,
        fn _ -> prepare_food_items(items_names) end,
        placeholders: %{now: now},
        on_conflict: :nothing
      )
      |> Multi.insert_all(
        :upsert_food_trucks,
        FoodTruck,
        fn _ -> prepare_food_trucks(params) end,
        placeholders: %{now: now},
        on_conflict: {:replace_all_except, [:id, :object_id]},
        conflict_target: [:object_id]
      )
      |> Multi.all(:food_items, fn _ -> from(fi in FoodItem, where: fi.name in ^items_names) end)
      |> Multi.all(:food_trucks, fn _ ->
        from(ft in FoodTruck, where: ft.object_id in ^object_ids)
      end)
      |> Multi.insert_all(
        :upsert_food_trucks_items,
        "food_trucks_items",
        fn %{food_items: food_items, food_trucks: food_trucks} ->
          food_items_map = Enum.map(food_items, &{&1.name, &1.id}) |> Map.new()
          food_trucks_map = Enum.map(food_trucks, &{&1.object_id, &1.id}) |> Map.new()

          Enum.flat_map(params, fn param ->
            object_id =
              (Map.get(param, "object_id") || Map.get(param, :object_id) || "")
              |> to_string()
              |> String.to_integer()

            (Map.get(param, "food_items") || Map.get(param, :food_items) || [])
            |> Enum.map(fn food_item_name ->
              %{
                food_item_id: Map.get(food_items_map, food_item_name),
                food_truck_id: Map.get(food_trucks_map, object_id)
              }
            end)
          end)
        end,
        on_conflict: :nothing
      )
      |> Multi.all(:food_trucks_with_food_items, fn _ ->
        from(ft in FoodTruck, where: ft.object_id in ^object_ids, preload: [:food_items])
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{food_trucks_with_food_items: food_trucks}} ->
        {:ok, food_trucks}

      {:error, failed_op, reason, _changes} ->
        message =
          "Failed to insert food trucks, failed operation: #{failed_op}, reason: #{inspect(reason)}"

        Logger.error(message)
        {:error, message}
    end
  end

  defp prepare_food_items(items_names) do
    items_names
    |> Enum.reduce_while([], fn name, acc ->
      changeset = FoodItem.create_changeset(%{name: name})

      case Ecto.Changeset.apply_action(changeset, :create) do
        {:ok, food_item} ->
          {:cont,
           [
             food_item
             |> Map.merge(%{
               inserted_at: {:placeholder, :now},
               updated_at: {:placeholder, :now}
             })
             |> Map.take(FoodItem.__schema__(:fields))
             |> Map.drop(FoodItem.__schema__(:primary_key))
             | acc
           ]}

        {:error, changeset} ->
          {:halt, {:error, changeset}}
      end
    end)
  end

  defp prepare_food_trucks(food_trucks) do
    food_trucks
    |> Enum.reduce_while([], fn food_truck, acc ->
      changeset = FoodTruck.create_changeset(food_truck)

      case Ecto.Changeset.apply_action(changeset, :create) do
        {:ok, food_truck} ->
          {:cont,
           [
             food_truck
             |> Map.merge(%{
               inserted_at: {:placeholder, :now},
               updated_at: {:placeholder, :now}
             })
             |> Map.take(FoodTruck.__schema__(:fields))
             |> Map.drop(FoodTruck.__schema__(:primary_key))
             | acc
           ]}

        {:error, changeset} ->
          {:halt, {:error, changeset}}
      end
    end)
  end

  @spec list_by(map()) :: {:ok, list(FoodTruck.t())} | {:error, term()}
  def list_by(filters = %{reference: reference}) do
    case Geocoder.call(reference) do
      {:ok, %Geocoder.Coords{lat: latitude, lon: longitude}} ->
        filters =
          filters
          |> Map.put(:coordinates, {longitude, latitude})
          |> Map.put(:radius, Map.get(filters, :radius, 500))

        do_list_by(filters)

      {:error, nil} ->
        {:error, "Invalid address"}
    end
  end

  def list_by(filters), do: do_list_by(filters)

  defp do_list_by(filters) do
    food_trucks =
      Queries.from_food_truck()
      |> Queries.filter_by(filters)
      |> Queries.with_distances(filters)
      |> Repo.all()

    {:ok, food_trucks}
  end
end
