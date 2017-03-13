defmodule Benchmark do
  require Logger

  @moduledoc """
  Performs basic benchmarking activities, i.e. running the TSP algorithms
  multiple times, saving the timing results to log file.
  """
  @algorithm_under_test "Cellular Algorithm: "

  # @algorithm  &Tsp.MasterSlave.run/0
  # @log_params Tsp.MasterSlave.get_log_params()

  # @algorithm  &Tsp.Island.run/0
  # @log_params Tsp.Island.get_log_params()

  # Cellular model config {2,2} the num_workers should be set to 2.
  # @algorithm (fn -> Tsp.Cellular.run(num_workers, {2,2}) end)
  @log_params Tsp.Cellular.get_log_params()

  @doc """
  Executes the measure function the number of times given by count.
  """
  def run(num_workers, count \\ 30) do
    display_start_message(num_workers)

    for run <- 1..count do
      Logger.info("Run #{run}: The algorithm ran in #{measure(fn -> Tsp.Cellular.run(num_workers, {2,3}) end)} seconds.")
    end
  end

  defp display_start_message(num_workers) do
    {{year, month, day}, _} = :calendar.local_time
    num_nodes = Cluster.number_nodes
    Logger.info("#{@algorithm_under_test} test, started on #{day}/#{month}/#{year} " <>
      "using #{num_nodes}x#{num_workers} worker processes")
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
