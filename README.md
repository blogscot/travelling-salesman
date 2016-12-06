# Tsp

The Travelling Salesman Problem, implemented using Elixir.

## Profiling

To profile the algorithm using `fprof` you can use the following command:

```
mix profile.fprof --details --callers --sort=own -e Tsp.run > output.txt
```

As `fprof` is a fairly intensive profiler its better to only run the algorithm for a small number of generations using the following settings:

### Settings
```
@num_cities 10
@min_distance 300
```

Also, to make `protocol dispatch` as efficient as possible, you need to consolidate protocols before profiling.

```
set "MIX_ENV=prod" && mix compile.protocols
iex -pa _build/prod/consolidated -S mix
```

You can verify a protocol is consolidated by checking its attributes:
```
iex(1)> Protocol.consolidated?(Enumerable)
true
```

## Resources

- [Erlang Profiling](http://erlang.org/doc/efficiency_guide/profiling.html)

