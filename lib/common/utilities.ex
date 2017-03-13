defmodule Utilities do

  @moduledoc """
  This module contains shared utility functions.
  """

  @doc """
  Divides a list into n subdivided lists.

  iex(2)> Utilities.divide([0,1,2,3,4,5,6,7,8,9], 3)
  [[7, 4, 1], [6, 5, 0], [9, 8, 3, 2]]

  """
  def divide(list, n), do:
    do_divide(list, List.duplicate([], n), [])

  defp do_divide([], o1, o2), do: o1 ++ o2
  defp do_divide([l|ls], [o|o1], o2), do: do_divide(ls, o1, [[l|o]|o2])
  defp do_divide(ls, [], o2), do: do_divide(ls, o2, [])


  # Clears all mailbox messages for the calling process
  def flush do
    receive do
      _msg ->
        flush()
    after
      10 -> :ok
    end
  end

end
