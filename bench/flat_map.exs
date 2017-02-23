defmodule FlatMapBench do
  use Benchfella

  def my_list, do: for x <- 1..1000, do: [x]

  bench "Map then append list", [list: my_list()] do
    list
    |> Enum.map(fn [x] -> [x * 2] end)
    |> :lists.append
  end

  bench "Map then flatten list", [list: my_list()] do
    list
    |> Enum.map(fn [x] -> [x * 2] end)
    |> List.flatten
  end

  bench "Flatmap list", [list: my_list()] do
    list
    |> Enum.flat_map(fn [x] -> [x * 2] end)
  end
end

# ## FlatMapBench
# benchmark name         iterations   average time
# Flatmap list                50000   62.89 µs/op
# Map then append list        50000   72.53 µs/op
# Map then flatten list       20000   77.86 µs/op
