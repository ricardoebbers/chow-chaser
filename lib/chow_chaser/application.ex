defmodule ChowChaser.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChowChaserWeb.Telemetry,
      ChowChaser.Repo,
      {DNSCluster, query: Application.get_env(:chow_chaser, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ChowChaser.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ChowChaser.Finch},
      # Start a worker by calling: ChowChaser.Worker.start_link(arg)
      # {ChowChaser.Worker, arg},
      # Start to serve requests, typically the last entry
      ChowChaserWeb.Endpoint,
      {Geocoder.Supervisor, geocoder_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChowChaser.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChowChaserWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def geocoder_config do
    Application.get_env(:chow_chaser, :geocoder)
  end
end
