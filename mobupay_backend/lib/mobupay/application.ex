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
      {Redix,
       host: System.get_env("REDIS_HOST"),
       port: redis_port(System.get_env("REDIS_PORT")),
       password: System.get_env("REDIS_PASSWORD"),
       name: :redix},
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

  def redis_port(port) when is_bitstring(port), do: String.to_integer(port)

  def redis_port(port) when is_integer(port), do: port
end
