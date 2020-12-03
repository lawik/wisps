defmodule Wisps.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Wisps.WispTracker, %{}},
      # Start the Telemetry supervisor
      WispsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Wisps.PubSub},
      # Start the Endpoint (http/https)
      {SiteEncrypt.Phoenix, WispsWeb.Endpoint}
      # Start a worker by calling: Wisps.Worker.start_link(arg)
      # {Wisps.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wisps.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WispsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
