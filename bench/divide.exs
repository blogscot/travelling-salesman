defmodule DivideBench do
  use Benchfella

  @population_small Population.new(10)
  @population_medium Population.new(60)
  @population_large Population.new(100)
  @parts 8

  # ## DivideBench
  # benchmark name              iterations   average time
  # Divide a small population     10000000   0.67 µs/op
  # Divide a medium population     1000000   2.86 µs/op
  # Divide a large population       500000   4.16 µs/op

  bench "Divide a small population" do
    Utilities.divide(@population_small, @parts)
  end

  bench "Divide a medium population" do
    Utilities.divide(@population_medium, @parts)
  end

  bench "Divide a large population" do
    Utilities.divide(@population_large, @parts)
  end

end
