defmodule CoinbasePro.MixProject do
  use Mix.Project

  def project do
    [
      app: :coinbase_pro,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decimal, "~>1.7.0"},
      {:httpoison, "~> 1.5"},
      {:jason, "~> 1.1"},
    ]
  end

  defp description do
    """
    Elixir wrapper for Coinbase Pro's REST API
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Rémi Louf"],
      name: :binance_ex,
    ]
  end
end
