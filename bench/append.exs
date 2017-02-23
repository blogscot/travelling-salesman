defmodule AppendBench do
  use Benchfella

  def my_list, do: for x <- 1..1000, do: [x]

  bench "Append to list", [list: my_list()] do
    [1,2,3,4,5] ++ list
  end

  bench "Erlang append to list", [list: my_list()] do
    :lists.append([1,2,3,4,5], list)
  end

  bench "Erlang flatten lists", [list: my_list()] do
    :lists.flatten([1,2,3,4,5], list)
  end

end

# ## AppendBench
# benchmark name         iterations   average time
# Append to list          100000000   0.04 µs/op
# Erlang append to list   100000000   0.04 µs/op
# Erlang flatten lists    100000000   0.09 µs/op
