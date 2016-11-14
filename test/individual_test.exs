defmodule IndividualTest do
  use ExUnit.Case
  doctest Individual

  test "Creating a new chromosome works" do
    assert Individual.new(20)
  end

  test "A chromosome is initialised non-randomly" do
    %Individual{chromosome: bob} = Individual.new(100)
    assert Individual.getGene(bob, 0) == 0
    assert Individual.getGene(bob, 99) == 99
  end

  test "A chromosome contains expected values" do
    %Individual{chromosome: bob} = Individual.new(100)
    for x <- 0..Individual.size(bob)-1, do:
      assert Individual.containsGene?(bob, x)
  end

  test "A chromosome has a size attribute" do
    %Individual{chromosome: bob} = Individual.new(88)
    assert Individual.size(bob) == 88
  end

  test "A mutated chromosome with mutation rate 0 is unchanged" do
    bob = Individual.new(10)

    assert bob |> Individual.mutate(0) == bob
  end

  test "A mutated chromosome with mutation rate 1 is changed" do
    bob = Individual.new(10)
    mutated_bob = bob |> Individual.mutate(1)

    refute mutated_bob == bob
    assert bob.chromosome |> Map.values |> Enum.sort ==
           mutated_bob.chromosome  |> Map.values |> Enum.sort
  end

end
