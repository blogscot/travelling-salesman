defmodule MultiArrayTest do
  use ExUnit.Case
  doctest MultiArray

  setup _context do
    list = 1..12 |> Enum.to_list
    [list: list]
  end

  test "creates a multi-dimensional array", context do
    result = Stream.cycle([0])
    |> Enum.take(9)
    |> MultiArray.from_list(3,3)
    assert result == [[0,0,0],[0,0,0],[0,0,0]]

    assert context[:list]
    |> MultiArray.from_list(6,2) ==
      [[1,2],[3,4],[5,6],[7,8],[9,10],[11,12]]
  end

  test "a incorrectly sized array raises an ArgumentError", context do
    assert_raise ArgumentError, fn ->
      context[:list]
      |> MultiArray.from_list(3,3)
    end
  end

  test "an array's values can be read", context do
    arr = context[:list] |> MultiArray.from_list(6,2)

    assert {0,0} |> MultiArray.get_value(arr) == 1
    assert {1,0} |> MultiArray.get_value(arr) == 3
    assert {2,1} |> MultiArray.get_value(arr) == 6
    assert {4,1} |> MultiArray.get_value(arr) == 10

    assert {6,1} |> MultiArray.get_value(arr) == nil
  end

  test "arrays can be converted back into lists", context do
    arr = context[:list] |> MultiArray.from_list(3,4)
    assert arr |> MultiArray.to_list == 1..12 |> Enum.to_list
  end

  test "a values position in an array can be found", context do
    arr = context[:list] |> MultiArray.from_list(2,6)

    assert arr |> MultiArray.find_index(1) == {0, 0}
    assert arr |> MultiArray.find_index(3) == {0, 2}
    assert arr |> MultiArray.find_index(5) == {0, 4}
    assert arr |> MultiArray.find_index(7) == {1, 0}
    assert arr |> MultiArray.find_index(9) == {1, 2}
    assert arr |> MultiArray.find_index(12) == {1, 5}
  end

  test "a non-present value returns nil", context do
    arr = context[:list] |> MultiArray.from_list(2,6)
    assert arr |> MultiArray.find_index(0) == nil
  end

  test "a multi-array has dimension properties", context do
    arr = context[:list] |> MultiArray.from_list(2,6)
    {row, col} = arr |> MultiArray.get_dimensions
    assert row == 2
    assert col == 6
  end

  #    0  1  2  3
  #  |-----------
  # 0| 1  2  3  4
  # 1| 5  6  7  8
  # 2| 9 10 11 12

  test "An array index is never out of bounds" do
    arr = 1..12 |> Enum.to_list |> MultiArray.from_list(3,4)

    assert {0,0} |> Cellular.sanatise(arr) == {0,0}
    assert {1,1} |> Cellular.sanatise(arr) == {1,1}
    assert {3,4} |> Cellular.sanatise(arr) == {0,0}
    assert {3,7} |> Cellular.sanatise(arr) == {0,3}
    assert {-1,3} |> Cellular.sanatise(arr) == {2,3}
    assert {2,-3} |> Cellular.sanatise(arr) == {2,1}
  end

end
