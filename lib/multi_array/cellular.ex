defmodule Cellular do

  @doc """
  Returns the values neighbouring the given value in array
  or nil if the value is not found.
  Neighbours are in north, east, south, west grid positions.
  """
  def find_neighbours(arr, value) when is_list(arr) do
    offsets = [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    case MultiArray.find_index(arr, value) do
      nil -> nil
      {row, col} ->
        offsets
        |> Enum.map(fn {r, c} ->
          {r + row, c + col}
          |> sanatise(arr)
          |> MultiArray.get_value(arr)
        end)
        |> Enum.uniq
    end
  end

  @doc """
  Wraps invalid, out of bounds, array indices so that they always
  specify a valid array element.
  """
  def sanatise({row, col}, arr) when is_list(arr) do
    {row_bound, col_bound} = MultiArray.get_dimensions(arr)
    {rem((row + row_bound), row_bound), rem((col + col_bound), col_bound)}
  end
end
