defmodule Workers.SyncTrucksTest do
  @moduledoc false
  use ChowChaser.DataCase, async: true
  use Oban.Testing, repo: ChowChaser.Repo

  alias Workers.SyncTrucks

  describe "perform job" do
    test "syncs food trucks" do
      assert {:ok, _trucks} = perform_job(SyncTrucks, %{})
    end
  end
end
