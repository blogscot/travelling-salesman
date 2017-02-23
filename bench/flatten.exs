defmodule FlattenBench do
  use Benchfella

  def my_list, do: for x <- 1..1000, do: [x] 

  bench "Elixir flatten list", [list: my_list()] do
    List.flatten(list)
  end

  bench "DIY append list", [list: my_list()] do
    list |> Enum.reduce(fn acc, x -> x ++ acc end)
  end

  bench "Erlang flatten list", [list: my_list()] do
    :lists.flatten(list)
  end

  bench "Erlang append list", [list: my_list()] do
    :lists.append(list)
  end

end

# ## FlattenBench
# benchmark name       iterations   average time
# Erlang append list       100000   25.20 µs/op
# Erlang flatten list       50000   31.36 µs/op
# Elixir flatten list       50000   31.70 µs/op
# DIY append list            1000   1790.47 µs/op
