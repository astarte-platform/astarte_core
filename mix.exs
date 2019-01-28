#
# This file is part of Astarte.
#
# Copyright 2017 Ispirata Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule Astarte.Core.Mixfile do
  use Mix.Project

  def project do
    [
      app: :astarte_core,
      version: "0.10.0-rc.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/astarte-platform/astarte_core",
      homepage_url: "https://astarte-platform.org/"
    ]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:cyanide, "== 0.5.0"},
      {:dialyxir, "== 0.5.1", only: [:dev], runtime: false},
      {:ecto, "== 2.2.10"},
      {:exprotobuf, "== 1.2.9"},
      {:poison, "== 3.1.0"},
      {:distillery, "== 1.5.2", runtime: false},
      {:excoveralls, "== 0.9.1", only: :test}
    ]
  end

  defp description do
    """
    Astarte Core library.
    """
  end

  defp package do
    [
      maintainers: ["Davide Bettio", "Riccardo Binetti"],
      licenses: ["LGPL-3.0-or-later"],
      links: %{
        "Astarte" => "https://astarte-platform.org",
        "Ispirata" => "https://ispirata.com",
        "GitHub" => "https://github.com/astarte-platform/astarte_core"
      }
    ]
  end
end
