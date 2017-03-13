
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
    pid2 = spawn __MODULE__, :dummy_worker, []
    pid3 = spawn __MODULE__, :dummy_worker, []
    pid4 = spawn __MODULE__, :dummy_worker, []

    arr = [worker1, pid2, pid3, pid4,]
    |> MultiArray.from_list(2,2)

    send worker1, {:calculate, arr, self()}
    assert wait_for(worker1) == [pid3, pid2]
  end

  #     0  1  2  3
  #  |------------
  # 0|  1  2  3  4
  # 1|  5  6  7  8
  # 2|  9 10 11 12

  test "A value in a 3x4 matrix has four neighbours" do
    pid1 = spawn __MODULE__, :dummy_worker, []
    pid2 = spawn __MODULE__, :dummy_worker, []
    worker3 = spawn __MODULE__, :test_worker, []
    pid4 = spawn __MODULE__, :dummy_worker, []
    pid5 = spawn __MODULE__, :dummy_worker, []
    pid6 = spawn __MODULE__, :dummy_worker, []
    pid7 = spawn __MODULE__, :dummy_worker, []
    pid8 = spawn __MODULE__, :dummy_worker, []
    pid9 = spawn __MODULE__, :dummy_worker, []
    pid10 = spawn __MODULE__, :dummy_worker, []
    pid11 = spawn __MODULE__, :dummy_worker, []
    pid12 = spawn __MODULE__, :dummy_worker, []

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
    pid1 = spawn __MODULE__, :dummy_worker, []
    pid2 = spawn __MODULE__, :dummy_worker, []
    pid3 = spawn __MODULE__, :dummy_worker, []
    pid4 = spawn __MODULE__, :dummy_worker, []
    pid5 = spawn __MODULE__, :dummy_worker, []
    pid6 = spawn __MODULE__, :dummy_worker, []
    pid7 = spawn __MODULE__, :dummy_worker, []
    pid8 = spawn __MODULE__, :dummy_worker, []
    pid9 = spawn __MODULE__, :dummy_worker, []
    pid10 = spawn __MODULE__, :dummy_worker, []
    worker11 = spawn __MODULE__, :test_worker, []
    pid12 = spawn __MODULE__, :dummy_worker, []
    pid13 = spawn __MODULE__, :dummy_worker, []
    pid14 = spawn __MODULE__, :dummy_worker, []
    pid15 = spawn __MODULE__, :dummy_worker, []
    pid16 = spawn __MODULE__, :dummy_worker, []

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
