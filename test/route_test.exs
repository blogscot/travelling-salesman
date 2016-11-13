defmodule RouteTest do
  use ExUnit.Case
  doctest Route

  test "A new route contains the correct cities" do
    bob = Individual.new(100)
    route1 = Route.new(bob)
    rob = bob |> Individual.shuffle
    route2 = Route.new(rob)

    refute bob == rob
    # refute that the routes are the same
    refute route1 == route2
    # Assert the sorted cities remain the same,
    # Therefore, the order is the only difference
    assert route1 |> Enum.sort == route2 |> Enum.sort
  end

  test "Correctly calculates the distance between cities" do
    expected_distance = :math.sqrt(8) * 2
    city1 = City.new({0, 0})
    city2 = City.new({2, 2})
    city3 = City.new({4, 4})
    dummyRoute = [city1, city2, city3]
    returnRoute = dummyRoute |> Enum.reverse
    longRoute = [city1, city3, city2]
    nonStopRoute = [city1, city3]

    assert Route.getDistance(dummyRoute) === expected_distance
    assert Route.getDistance(returnRoute) === expected_distance
    assert Route.getDistance(nonStopRoute) === expected_distance
    assert Route.getDistance(longRoute) === :math.sqrt(8) * 3
  end
end
