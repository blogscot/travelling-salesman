defmodule City do
  defstruct xPos: 0, yPos: 0

  @moduledoc """
  Contains the representation of a city for the Travelling Salesman Problem.
  """


  @doc """
  Creates a new City based on the given x, y coordinates.
  """

  def new({x, y}) do
    %City{xPos: x, yPos: y}
  end

  @doc """
  Calculates the Euclidian distance between two cities.
  """

  def distanceFrom(%City{xPos: x1, yPos: y1}, %City{xPos: x2, yPos: y2}) do
    deltaX = :math.pow((x1-x2), 2)
    deltaY = :math.pow((y1-y2), 2)
    :math.sqrt(deltaX + deltaY)
  end

end
