defmodule Route do


  @doc """
  Decodes the chromosome replacing each gene with the
  a new city instance.
  """

  def new(chromosome) when is_map(chromosome) do
    for gene <- chromosome do
      Cities.get_cities[elem(gene, 1)]
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
