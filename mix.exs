defmodule TowerErrorTracker.MixProject do
  use Mix.Project

  @description "Tower reporter for ErrorTracker"
  @source_url "https://github.com/mimiquate/tower_error_tracker"
  @version "0.3.0"

  def project do
    [
      app: :tower_error_tracker,
      description: @description,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),

      # Docs
      name: "TowerErrorTracker",
      source_url: @source_url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      included_applications: [:error_tracker],
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tower, "~> 0.6.0"},
      {:error_tracker, "~> 0.3", runtime: false},

      # Dev
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false},
      {:blend, "~> 0.4.1", only: :dev},

      # Test
      {:assert_eventually, "~> 1.0", only: :test},
      {:ecto_sqlite3, "~> 0.17.2", only: :test},
      {:plug_cowboy, "~> 2.7", only: :test},
      {:bandit, "~> 1.5", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
