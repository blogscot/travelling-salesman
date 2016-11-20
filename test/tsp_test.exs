defmodule TspTest do
  use ExUnit.Case
  doctest Tsp

  test "The initial population can calculate its distance" do
    population =
      Population.new(35)
      |> GeneticAlgorithm.evaluate

    assert map_size(population) == 35
    assert Tsp.calculate_distance(population) == 1896.5386218258702
  end

end