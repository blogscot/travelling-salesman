defmodule CityTest do
  use ExUnit.Case
  doctest City

  test "The distance between A and A is zero" do
    cityA = City.new({0, 0})
    assert City.distanceFrom(cityA, cityA) == 0
  end

  test "The distance between 0, 0 and 2, 2 is sqrt(8)" do
    cityA = City.new({0, 0})
    cityB = City.new({2, 2})
    assert City.distanceFrom(cityA, cityB) == :math.sqrt(8)
  end
end
