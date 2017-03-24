defmodule Tsp.Mixfile do
  use Mix.Project

  def project do
    [app: :tsp,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :array]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:array, github: "blogscot/elixir-array"},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:exprof, "~> 0.2.0", only: [:dev, :test]},
      {:eflame, "~> 1.0", only: [:dev, :test]},
      {:benchfella, "~> 0.3.0", only: :dev},
      {:logger_file_backend, "~> 0.0.9", only: [:dev, :test]},
      {:earmark, "~> 1.1", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end
end
