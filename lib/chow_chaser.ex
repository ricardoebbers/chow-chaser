defmodule ChowChaser do
  @moduledoc """
  ChowChaser keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias ChowChaser.FoodTrucks
  alias ChowChaser.Models.Truck

  @spec upsert_all(list(map())) :: {:ok, list(Truck.t())} | {:error, term()}
  defdelegate upsert_all(args), to: FoodTrucks

  @spec list_all() :: list(Truck.t())
  defdelegate list_all, to: FoodTrucks

  @spec list_by(map()) :: list(Truck.t())
  defdelegate list_by(filters), to: FoodTrucks

  @spec search_params() :: Ecto.Changeset.t()
  defdelegate search_params, to: FoodTrucks
end
