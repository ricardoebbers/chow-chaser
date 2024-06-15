defmodule ChowChaser.FoodTrucks do
  @moduledoc """
  The FoodTrucks context.
  """

  import Ecto.Query, warn: false
  alias ChowChaser.Repo

  alias ChowChaser.FoodTrucks.FoodTruck

  @doc """
  Returns all food trucks.

  ## Examples

      iex> all()
      [%FoodTruck{}, ...]

  """
  def all do
    Repo.all(FoodTruck)
  end
end
