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
    date_info = "#{day}/#{month}/#{year}"
    num_workers = Cluster.number_workers
    num_nodes = Cluster.number_nodes
    Logger.info("Test started on #{date_info} using #{num_nodes}x#{num_workers} worker processes")

    %{min_distance: min_distance, population_size: population_size,
      crossover_rate: crossover_rate, mutation_rate: mutation_rate,
      elitism_count: elitism_count, tournament_size: tournament_size} = @log_params

    distance_info = "Distance: #{min_distance}"
    population_info = "Population: #{population_size}"
    crossover_info = "Crossover: #{crossover_rate}"
    mutation_info = "Mutation: #{mutation_rate}"
    elitism_info = "Elitism: #{elitism_count}"
    tournament_info = "Tournament: #{tournament_size}"

    Logger.info("Params: #{distance_info} #{population_info}, #{crossover_info}, " <>
      "#{mutation_info}, #{elitism_info}, #{tournament_info}")
  end

  # Measures the time taken to execute the given function.
  defp measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end

end
