defmodule ChowChaser.Queries.Item do
  @moduledoc """
  Queries for the  aggregate.
  """

  alias ChowChaser.Models.Item

  import Ecto.Query

  @type queryable :: Item | Ecto.Query.t()

  @spec new :: queryable()
  def new do
    from(Item, as: :item)
  end

  @spec filter_by(queryable(), map()) :: queryable()
  def filter_by(queryable, filters) do
    valid_filters = Item.__schema__(:fields)

    filters =
      filters
      |> Map.take(valid_filters)
      |> Enum.reject(fn {_, value} -> is_nil(value) end)
      |> Keyword.new()

    Enum.reduce(filters, queryable, fn
      {field, value}, queryable when is_list(value) ->
        where(queryable, [item: i], field(i, ^field) in ^value)

      {field, value}, queryable ->
        where(queryable, [item: i], field(i, ^field) == ^value)
    end)
  end

  @spec with_trucks(queryable()) :: queryable()
  def with_trucks(queryable) do
    preload(queryable, [:trucks])
  end
end
