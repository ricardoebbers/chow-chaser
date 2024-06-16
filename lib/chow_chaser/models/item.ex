defmodule ChowChaser.Models.Item do
  @moduledoc """
  The Items schema.

  This schema represents the items table in the database.
  """

  use ChowChaser.Schema

  alias ChowChaser.Models.Truck
  alias ChowChaser.Queries.Item, as: ItemQueries
  alias Ecto.Multi

  @type t :: %__MODULE__{}
  @type changeset :: Ecto.Changeset.t(t())

  @items_separator ":"

  schema "items" do
    field :name, :string

    many_to_many :trucks, Truck,
      join_through: "trucks_items",
      preload_order: [asc: :applicant],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), map()) :: changeset()
  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  @spec bulk_upsert_multi(Multi.t(), list(map()), map(), DateTime.t()) :: Ecto.Multi.t()
  def bulk_upsert_multi(multi, params, object_ids_to_item_names, timestamp) do
    item_names = Map.values(object_ids_to_item_names) |> List.flatten()
    item_query = ItemQueries.new() |> ItemQueries.filter_by(%{name: item_names})

    multi
    |> Multi.insert_all(
      :upsert_items,
      __MODULE__,
      params,
      placeholders: %{now: timestamp},
      on_conflict: :nothing
    )
    |> Multi.all(:items, item_query)
  end

  def prepare_names(params = %{items: items}) do
    %{params | items: cleanup_names(items)}
  end

  def prepare_names(params = %{"items" => items}) do
    %{params | "items" => cleanup_names(items)}
  end

  def prepare_names(params), do: params

  defp cleanup_names(names) do
    cleanup_fun = &String.split(String.capitalize(to_string(&1)), @items_separator)

    names
    |> List.wrap()
    |> Enum.flat_map(cleanup_fun)
    |> Enum.map(&String.trim(&1))
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end
end
