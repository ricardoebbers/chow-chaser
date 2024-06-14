defmodule ChowChaser.Repo do
  use Ecto.Repo,
    otp_app: :chow_chaser,
    adapter: Ecto.Adapters.Postgres
end
