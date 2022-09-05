defmodule Mobupay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Mobupay.Repo,
      # Start the Telemetry supervisor
      MobupayWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mobupay.PubSub},
      # Start the Endpoint (http/https)
      MobupayWeb.Endpoint,
      {Redix, name: :redix},
      # {Redix, host: "redis-18910.c84.us-east-1-2.ec2.cloud.redislabs.com:18910", name: :redix},
      {Task.Supervisor, name: Mobupay.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mobupay.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MobupayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
