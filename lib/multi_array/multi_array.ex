defmodule MultiArray do

  @moduledoc """
  This module provides a pseudo multi-dimensional array implementation.
  """

  @doc """
  Constructs a multi-dimensional array using the given dimensions.
  """
  def from_list(arr, row, col) when is_list(arr) do
    unless (length(arr) == row * col) and
    rem(length(arr), col) == 0 do
      raise ArgumentError, "Invalid array size."
    end

    arr |> Enum.chunk(col)
  end

  @doc """
  Converts the multi-dimensional array into a arr.
  """
  def to_list(arr) when is_list(arr) do
    Enum.concat(arr)
  end

  @doc """
  Returns the {row, col} position of the first encountered given value
  in the array.
  """
  def find_index(arr, value) when is_list(arr) and length(arr) > 0 do
      case Enum.find_index(to_list(arr), &(&1==value)) do
      nil -> nil
      pos ->
        {_, num_cols} = get_dimensions(arr)
        {div(pos, num_cols), rem(pos, num_cols)}
    end
  end

  @doc """
  Returns an array value for the given row and column.
  If index out of bounds returns nil.
  """
  def get_value({row, col}, arr) do
    try do
      arr
      |> Enum.at(row)
      |> Enum.at(col)
    rescue
      Protocol.UndefinedError -> nil
    end
  end

  @doc """
  Returns the column size of the array.
  """
  def get_dimensions(arr) when is_list(arr) do
    row = arr |> length
    col = arr |> Enum.at(0) |> length
    {row, col}
  end

  @doc """
  Wraps invalid, out of bounds, array indices so that they always
  specify a valid array element.
  """
  def sanitise({row, col}, arr) when is_list(arr) do
    {row_bound, col_bound} = MultiArray.get_dimensions(arr)
    {rem((row + row_bound), row_bound), rem((col + col_bound), col_bound)}
  end

end
