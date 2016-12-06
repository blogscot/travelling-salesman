defmodule Example do
  use Bmark

  bmark :new_route, runs: 50 do

    for _ <- 1..100, do:
      Route.new2(Individual.new(100) |> Individual.shuffle)
  end

end