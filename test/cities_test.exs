defmodule CitiesTest do
  use ExUnit.Case
  doctest Cities

  test "The cities data is initialised correctly" do
    cities = Cities.get_cities
    assert {10, 4} == cities[0]
    assert {30, 65} == cities[3]
  end
end