defmodule AstarteCore.Mixfile do
  use Mix.Project

  def project do
    [app: :astarte_core,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:amqp, "~> 0.2.2"},
      {:poison, "~> 3.1"},

      {:distillery, "~> 1.4", runtime: false},

      {:excoveralls, "~> 0.6", only: :test},
    ]
  end
end
