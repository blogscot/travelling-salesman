defmodule Benchmark do
  require Logger

  @moduledoc """
  Performs basic benchmarking activities, i.e. running the TSP algorithms
  multiple times, saving the timing results to log file.
  """

  @algorithm &MasterSlave.Tsp.run/0

  @doc """
  Executes the measure function the number of times given by count.
  """
  def run(count \\ 30) do

    {{year, month, day}, _} = :calendar.local_time
    Logger.info("Test started on #{day}/#{month}/#{year}")

    for run <- 1..count do
      Logger.info("Run #{run}: The algorithm ran in #{measure(@algorithm)} seconds.")
    end
  end


  # Measures the time taken to execute the given function.
  defp measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end

end
