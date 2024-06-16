defmodule ChowChaser do
  @moduledoc """
  ChowChaser keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias ChowChaser.FoodTrucks

  @spec upsert_all(list(FoodTrucks.FoodTruck.params())) ::
          {:ok, list(FoodTrucks.FoodTruck.t())} | {:error, term()}
  defdelegate upsert_all(args), to: FoodTrucks
end
