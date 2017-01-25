defmodule Utilities do

  def divide(list, n), do:
    do_divide(list, List.duplicate([], n), [])

  defp do_divide([], o1, o2), do: o1 ++ o2
  defp do_divide([l|ls], [o|o1], o2), do: do_divide(ls, o1, [[l|o]|o2])
  defp do_divide(ls, [], o2), do: do_divide(ls, o2, [])

end