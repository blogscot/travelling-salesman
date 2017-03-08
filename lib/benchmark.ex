defmodule Benchmark do
  require Logger

  @moduledoc """
  Performs basic benchmarking activities, i.e. running the TSP algorithms
  multiple times, saving the timing results to log file.
  """

  @algorithm  &Tsp.Island.run/0
  @log_params Tsp.Island.get_log_params()

  @doc """
  Executes the measure function the number of times given by count.
  """
  def run(count \\ 30) do
    display_start_message()

    for run <- 1..count do
      Logger.info("Run #{run}: The algorithm ran in #{measure(@algorithm)} seconds.")
    end
  end

  defp display_start_message do
    {{year, month, day}, _} = :calendar.local_time
    num_workers = Cluster.number_workers
    num_nodes = Cluster.number_nodes
    Logger.info("Test started on #{day}/#{month}/#{year} using #{num_nodes}x#{num_workers} worker processes")
    Logger.info(@log_params)
  end

  # Measures the time taken to execute the given function.
  defp measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end

end
