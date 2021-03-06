defmodule Route do

  @moduledoc """
  Each Route is a possible path through the list of cities.
  """


  @doc """
  Decodes the chromosome replacing each gene with
  a new city instance.
  """
  def new(%Individual{chromosome: chromosome}) do
    cities = Cities.get_cities

    # its more efficient to iterate over lists than arrays
    list = chromosome |> Array.to_list
    for gene <- list do
      cities[gene]
      |> City.new
    end
  end


  @doc """
  Calculates the total distance for a route.
  """
  def getDistance(route) when is_list(route) do
    route
    |> Enum.chunk(2, 1)
    |> Enum.map(fn [city1, city2] ->
        City.distanceFrom(city1, city2)
    end) |> Enum.sum
  end
end
