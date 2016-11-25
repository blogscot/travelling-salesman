defmodule ArrayTest do
  use ExUnit.Case
  doctest ArrayExamples

  test "Creating a new chromosome works" do
    assert ArrayExamples.new(20)
  end

  test "A chromosome is initialised non-randomly" do
    bob = ArrayExamples.new(100)
    assert ArrayExamples.getGene(bob, 0) == 0
    assert ArrayExamples.getGene(bob, 99) == 99
  end

  test "A chromosome contains expected values" do
    bob = ArrayExamples.new(100)
    size = ArrayExamples.size(bob)

    for x <- 0..size-1, do:
      assert ArrayExamples.containsGene?(bob, x)
  end

  test "An chromosome can have its genes updated" do
    bob = ArrayExamples.new(100)
    size = ArrayExamples.size(bob)

    for offset <- 0..size-1 do
      new_bob = bob |> ArrayExamples.setGene(offset, 1)

      assert bob |> ArrayExamples.getGene(offset) == offset
      assert new_bob |> ArrayExamples.getGene(offset) == 1
    end
  end

  test "A chromosome only contains expected values" do
    bob = ArrayExamples.new(10)

    assert ArrayExamples.containsGene?(bob, 0)
    assert ArrayExamples.containsGene?(bob, 9)
    refute ArrayExamples.containsGene?(bob, 10)
    refute ArrayExamples.containsGene?(bob, 33)
  end

  test "A chromosome can have its genes swapped" do
    bob = ArrayExamples.new(100)

    new_bob = bob |> ArrayExamples.swapGenes(33, 55)
    assert new_bob |> ArrayExamples.getGene(33) == 55
    assert new_bob |> ArrayExamples.getGene(55) == 33
  end

  test "A mutated chromosome with mutation rate 0 is unchanged" do
    bob = ArrayExamples.new(10)

    assert bob |> ArrayExamples.mutate(0) |> Array.equal?(bob)
  end

  test "A mutated chromosome with mutation rate 1 is changed" do
    bob = ArrayExamples.new(10)
    mutated_bob = bob |> ArrayExamples.mutate(1)

    refute mutated_bob == bob
    assert bob |> Array.to_list |> Enum.sort ==
           mutated_bob |> Array.to_list |> Enum.sort
  end

end
