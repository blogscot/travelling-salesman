defmodule Benchmark do
  require Logger

  @moduledoc """
  Performs basic benchmarking activities, i.e. running the TSP algorithms
  multiple times, saving the timing results to log file.
  """

  @doc """
  Executes the Master Slave Model algorithm using the given number of workers.
  The algorithm is repeated n times, specified by the count parameter.
  """
  def run_master_slave(num_workers, count \\ 30) do
    display_start_message("MasterSlave", num_workers, Tsp.MasterSlave.get_log_params())

    for run <- 1..count do
      Logger.info("Run #{run}: The algorithm ran in #{measure(fn -> Tsp.MasterSlave.run(num_workers) end)} seconds.")
    end
  end

  @doc """
  Executes the Island Model algorithm using the given number of workers.
  The algorithm is repeated n times, specified by the count parameter.
  """
  def run_island(num_workers, count \\ 30) do
    display_start_message("Island", num_workers, Tsp.Island.get_log_params())

    for run <- 1..count do
      Logger.info("Run #{run}: The algorithm ran in #{measure(fn -> Tsp.Island.run(num_workers) end)} seconds.")
    end
  end

  @doc """
  Executes the Cellular Model algorithm using the given number of workers.
  The algorithm is repeated n times, specified by the count parameter.

  Valid grid dimensions:
  For each connected node num_workers will be spawned. Thus, for two
  workers each running on two connected nodes the total number of workers is four.
  Therefore, the number of workers in the grid should equal four. E.g. a {2,2}
  grid has valid dimensions.
  """
  def run_cellular(num_workers, {row, col}, count \\ 30) do
    display_start_message("Cellular", num_workers, Tsp.Cellular.get_log_params())

    for run <- 1..count do
      Logger.info("Run #{run}: The algorithm ran in #{measure(fn -> Tsp.Cellular.run(num_workers, {row,col}) end)} seconds.")
    end
  end

  defp display_start_message(algorithm_name, num_workers, log_params) do
    {{year, month, day}, _} = :calendar.local_time
    num_nodes = Cluster.number_nodes
    Logger.info("#{algorithm_name} algorithm test, started on #{day}/#{month}/#{year} " <>
      "using #{num_nodes}x#{num_workers} worker processes")
    Logger.info(log_params)
  end

  # Measures the time taken to execute the given function.
  defp measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end

end
