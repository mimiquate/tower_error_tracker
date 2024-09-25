defmodule TowerErrorTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :tower_error_tracker,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
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
      {:tower, "~> 0.5.0"},
      {:error_tracker, "~> 0.3.0", runtime: false},

      # Test
      {:assert_eventually, "~> 1.0", only: :test},
      {:ecto_sqlite3, "~> 0.17.2", only: :test}
    ]
  end
end
