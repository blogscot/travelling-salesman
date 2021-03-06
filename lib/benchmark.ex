defmodule Benchmark do
  require Logger

  @moduledoc """
  Performs basic benchmarking activities, i.e. running the TSP algorithms
  multiple times, saving the timing results to log file.
  """

  @doc """
  Runs the TSP parallel and distributed algorithms over the given range of
  processor cores.

  Example:
    Benchmark.bench(%{algorithm: :master_slave}, 1, 4)

  The will run the master_slave algorithm over one to four cores on the machines
  specified in the config.exs file.
  """
  def bench(%{algorithm: name}, start, finish) do
    case name do
      :master_slave ->
        for n <- start..finish, do: run_master_slave(n)
      :island ->
        for n <- start..finish, do: run_island(n)
      :cellular ->
        num_nodes = Cluster.get_nodes |> length
        for n <- start..finish, do: run_cellular(n, {num_nodes, n})
      _ ->
       IO.puts "Invalid algorithm type given. Choices are [:master_slave, :island, :cellular]."
    end
  end

  @doc """
  Executes the sequential TSP algorithm
  The algorithm is repeated n times, specified by the count parameter.
  """
  def run_sequential(count \\ 30) do
    display_start_message("Sequential TSP", 1, Tsp.get_log_params())

    for run <- 1..count do
      Logger.info("Run #{run}: The algorithm ran in #{measure(&Tsp.run/0)} seconds.")
    end
  end

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
  def run_island(num_workers, async? \\ false, count \\ 30) do
    if async? do
      display_start_message("Island (Async)", num_workers, Tsp.Island.Async.get_log_params())
    else
      display_start_message("Island", num_workers, Tsp.Island.Async.get_log_params())
    end

    for run <- 1..count do
      case async? do
        true ->
          Logger.info("Run #{run}: The algorithm ran in #{measure(fn -> Tsp.Island.Async.run(num_workers) end)} seconds.")
        _ ->
          Logger.info("Run #{run}: The algorithm ran in #{measure(fn -> Tsp.Island.run(num_workers) end)} seconds.")
      end
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
  def run_cellular(num_workers, {row, col}, async? \\ false, count \\ 30) do
    if async? do
      display_start_message("Cellular (Async)", num_workers, Tsp.Cellular.Async.get_log_params())
    else
      display_start_message("Cellular", num_workers, Tsp.Cellular.get_log_params())
    end

    for run <- 1..count do
      case async? do
        true ->
          Logger.info("Run #{run}: The algorithm ran in #{measure(fn -> Tsp.Cellular.Async.run(num_workers, {row,col}) end)} seconds.")
        _ ->
          Logger.info("Run #{run}: The algorithm ran in #{measure(fn -> Tsp.Cellular.run(num_workers, {row,col}) end)} seconds.")
      end
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
