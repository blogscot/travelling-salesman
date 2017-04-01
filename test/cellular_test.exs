
defmodule CellularTest do
  use ExUnit.Case
  doctest Tsp.Cellular

  def dummy_worker do
    receive do
      {:calculate, _workers, _from} ->
        true
    end
  end

  # Calculates the neighbours list for a given set of worker pids
  def test_worker do
    receive do
      {:calculate, workers, from} ->
        neighbours = Tsp.Cellular.calculate_neighbours(workers)
        send from, {self(), neighbours: neighbours}
        test_worker()
    end
  end

  # Spawn a dummy process
  def spawn_dummy do
    spawn __MODULE__, :dummy_worker, []
  end

  # Waits for the neighbours results from the worker process
  def wait_for(worker) do
    receive do
      {^worker, neighbours: neighbours} ->
        neighbours
    end
  end

  #    0  1
  #  |-----
  # 0| 1  2
  # 1| 3  4

  test "A value in a 2x2 matrix has two neighbours" do
    worker1 = spawn __MODULE__, :test_worker, []
    pid2 = spawn_dummy()
    pid3 = spawn_dummy()
    pid4 = spawn_dummy()

    arr = [worker1, pid2, pid3, pid4,]
    |> MultiArray.from_list(2,2)

    send worker1, {:calculate, arr, self()}
    assert wait_for(worker1) == [pid3, pid2]
  end

  #     0  1  2  3  4  5
  #  |------------------
  # 0|  1  2  3  4  5  6

  test "An array with one row has two neighbours" do
    worker1 = spawn __MODULE__, :test_worker, []
    pid2 = spawn_dummy()
    pid3 = spawn_dummy()
    pid4 = spawn_dummy()
    pid5 = spawn_dummy()
    pid6 = spawn_dummy()

    arr = [worker1, pid2, pid3, pid4, pid5, pid6]
    |> MultiArray.from_list(1,6)

    send worker1, {:calculate, arr, self()}
    assert wait_for(worker1) == [pid2, pid6]
  end

  #     0  1  2  3
  #  |------------
  # 0|  1  2  3  4
  # 1|  5  6  7  8
  # 2|  9 10 11 12

  test "A value in a 3x4 matrix has four neighbours" do
    pid1 = spawn_dummy()
    pid2 = spawn_dummy()
    worker3 = spawn __MODULE__, :test_worker, []
    pid4 = spawn_dummy()
    pid5 = spawn_dummy()
    pid6 = spawn_dummy()
    pid7 = spawn_dummy()
    pid8 = spawn_dummy()
    pid9 = spawn_dummy()
    pid10 = spawn_dummy()
    pid11 = spawn_dummy()
    pid12 = spawn_dummy()

    arr = [
      pid1, pid2, worker3, pid4, pid5, pid6,
      pid7, pid8, pid9, pid10, pid11, pid12
    ] |> MultiArray.from_list(3,4)

    send worker3, {:calculate, arr, self()}
    assert wait_for(worker3) == [pid11, pid4, pid7, pid2]
  end

  #     0  1  2  3
  #  |------------
  # 0|  1  2  3  4
  # 1|  5  6  7  8
  # 2|  9 10 11 12
  # 3| 13 14 15 16

  test "An value in a 4x4 matrix has four neighbours" do
    pid1 = spawn_dummy()
    pid2 = spawn_dummy()
    pid3 = spawn_dummy()
    pid4 = spawn_dummy()
    pid5 = spawn_dummy()
    pid6 = spawn_dummy()
    pid7 = spawn_dummy()
    pid8 = spawn_dummy()
    pid9 = spawn_dummy()
    pid10 =spawn_dummy()
    worker11 = spawn __MODULE__, :test_worker, []
    pid12 = spawn_dummy()
    pid13 = spawn_dummy()
    pid14 = spawn_dummy()
    pid15 = spawn_dummy()
    pid16 = spawn_dummy()

    arr = [
      pid1, pid2, pid3, pid4,
      pid5, pid6, pid7, pid8,
      pid9, pid10, worker11, pid12,
      pid13, pid14, pid15, pid16
    ] |> MultiArray.from_list(4,4)

    send worker11, {:calculate, arr, self()}
    assert wait_for(worker11) == [pid7, pid12, pid15, pid10]
  end

end
