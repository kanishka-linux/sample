defmodule SM.MixProject do
  use Mix.Project

  def project do
    [
      app: :sample,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:randex, git: "https://github.com/ananthakumaran/randex", tag: "v0.4.0"},
      {:stream_data, "~>0.1"},
      {:poison, "~>3.1"},
      {:ex_json_schema, "~> 0.5.4"}
    ]
  end
end
