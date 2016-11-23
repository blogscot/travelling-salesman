defmodule Benchmark do

  @doc """
  Runs and displays the time taken for  the TSP algorithm.
  """

  def measure do
    (fn -> Tsp.run end)
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
    |> (fn duration -> IO.puts("The algorithm ran in #{duration} seconds.") end).()
  end

  @doc """
  Executes the measure function the number of times given by count.
  """

  def run(count \\ 1), do: for _ <- 1..count, do: measure

end