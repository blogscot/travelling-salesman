defmodule RoutesBench do
  use Benchfella

  def individual, do: Individual.new(100)
  def route, do: Route.new(individual())

  bench "Get a new Route", [individual: individual()] do
    Route.new(individual)
  end

  bench "Calculate a route's distance", [route: route()] do
    Route.getDistance(route)
  end

end
