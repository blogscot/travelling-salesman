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

  test "An individual can be created using a list" do
    chromosome = 0..19 |> Enum.to_list
    bob = Individual.from_list({chromosome, nil})

    assert bob == Individual.new(20)
  end

  test "An individual can be expressed as a list" do
    chromosome = 0..19 |> Enum.to_list
    bob = Individual.new(20)
    {bob_list, _fitness} = bob |> Individual.to_list

    assert bob_list == chromosome
  end

  test "An individual can be converted to a list and back" do
    bob = Individual.new(60)

    assert bob |> Individual.to_list |> Individual.from_list == bob
  end

  test "A chromosome contains expected values" do
    %Individual{chromosome: bob} = Individual.new(100)
    for x <- 0..map_size(bob)-1, do:
      assert Individual.containsGene?(bob, x)
  end

  test "An chromosome can have its genes updated" do
    %Individual{chromosome: bob} = Individual.new(100)

    for offset <- 0..map_size(bob)-1 do
      new_bob = bob |> Individual.setGene(offset, 1)

      assert bob |> Individual.getGene(offset) == offset
      assert new_bob |> Individual.getGene(offset) == 1
    end
  end

  test "A chromosome only contains expected values" do
    %Individual{chromosome: bob} = Individual.new(10)

    assert Individual.containsGene?(bob, 0)
    assert Individual.containsGene?(bob, 9)
    refute Individual.containsGene?(bob, 10)
    refute Individual.containsGene?(bob, 33)
  end

  test "A chromosome can have its genes swapped" do
    %Individual{chromosome: bob} = Individual.new(100)

    new_bob = bob |> Individual.swapGenes(33, 55)
    assert new_bob |> Individual.getGene(33) == 55
    assert new_bob |> Individual.getGene(55) == 33
  end

  test "A mutated chromosome with mutation rate 0 is unchanged" do
    bob = Individual.new(10)

    assert bob |> Individual.mutate(0) == bob
  end

  test "A mutated chromosome with mutation rate 1 is changed" do
    bob = Individual.new(10)
    mutated_bob = bob |> Individual.mutate(1)

    refute mutated_bob == bob
    assert bob.chromosome |> Array.to_list |> Enum.sort ==
           mutated_bob.chromosome |> Array.to_list |> Enum.sort
  end

end
