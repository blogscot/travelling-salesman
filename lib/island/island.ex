defmodule Tsp.Island do

  def run do
    pool = Cluster.create_worker_pool(&start/0)
    IO.puts "#{inspect pool}"
    IO.puts "#{calculate_neighbours([1])}"
  end

  @doc """
  Returns the neighbouring process pids.

  Given an ordered list of pids the neighbours are the ones
  immediately before and after the current pid.
  """
  def calculate_neighbours(workers) when is_list(workers) do
    # find current pid index in list of worker pids
    index = Enum.find_index(workers, &(&1==self()))

    len = length(workers)
    previous = rem (index - 1) + len, len
    next = rem (index + 1), len
    case len do
      1 -> []
      2 ->
        [workers |> Enum.at(previous)]
      _ ->
        [workers |> Enum.at(previous), workers |> Enum.at(next)]
    end
  end

  defp start() do
    _neighbours = get_neighbours()
  #   # Evaluate the initial population
  #   population =
  #     population.new(@population_size)
  #     |> GeneticAlgorithm.evaluate()

  #   process_population(population, pool, 1, distance)
  end

  defp get_neighbours() do
    receive do
      {:neighbours, neighbours} ->
        neighbours
    end
  end
end
