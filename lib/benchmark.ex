defmodule Benchmark do
  require Logger

  @moduledoc """
  Performs basic benchmarking activities, i.e. running the TSP algorithms
  multiple times, saving the timing results to log file.
  """

  @algorithm &Tsp.MasterSlave.run/0

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
    date_info = "#{day}/#{month}/#{year}"
    num_workers = Cluster.number_workers
    num_nodes = Cluster.number_nodes
    Logger.info("Test started on #{date_info} using #{num_nodes}x#{num_workers} worker processes")

    {population_size, crossover_rate, mutation_rate} = Tsp.MasterSlave.log_params()
    population_info = "Population Size: #{population_size}"
    crossover_info = "Crossover Rate: #{crossover_rate}"
    mutation_info = "Mutation Rate: #{mutation_rate}"
    Logger.info("Params: #{population_info}, #{crossover_info} #{mutation_info}")
  end

  # Measures the time taken to execute the given function.
  defp measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end

end
