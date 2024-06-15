defmodule ChowChaser.Factory do
  @moduledoc """
  The Factory module.
  """
  use ExMachina.Ecto, repo: ChowChaser.Repo
  use ChowChaser.Factory.FoodTrucksFactory
end
