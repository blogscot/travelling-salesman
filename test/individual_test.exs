defmodule IndividualTest do
  use ExUnit.Case
  doctest Individual

  test "Creating a new chromosome works" do
    assert Individual.new(20)
  end

  test "A chromosome is initialised non-randomly" do
    bob = Individual.new(100)
    assert Individual.getGene(bob, 0) == 0
    assert Individual.getGene(bob, 99) == 99
  end

  test "A chromosome contains expected values" do
    bob = Individual.new(100)
    for x <- bob, do:
      assert Individual.containsGene(bob, x)
  end

  test "A chromosome has a size attribute" do
    bob = Individual.new(88)
    assert Individual.size(bob) == 88
  end

end
