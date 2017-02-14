defmodule IslandTest do
  use ExUnit.Case
  doctest Tsp.Island

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
        neighbours = Tsp.Island.calculate_neighbours(workers)
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

  test "A single process has no neighbours" do
    worker = spawn __MODULE__, :test_worker, []
    send worker, {:calculate, [worker], self()}
    assert wait_for(worker) == []
  end

  test "Two processes have each other as neighbours" do
    worker1 = spawn __MODULE__, :test_worker, []
    worker2 = spawn __MODULE__, :dummy_worker, []

    workers = [worker1, worker2]
    send worker1, {:calculate, workers, self()}
    assert wait_for(worker1) == [worker2]
  end

  test "Three processes have each have two neighbours" do
    worker1 = spawn __MODULE__, :test_worker, []
    worker2 = spawn __MODULE__, :dummy_worker, []
    worker3 = spawn __MODULE__, :dummy_worker, []

    workers = [worker1, worker2, worker3]
    send worker1, {:calculate, workers, self()}
    assert wait_for(worker1) == [worker3, worker2]

    workers = [worker2, worker1, worker3]
    send worker1, {:calculate, workers, self()}
    assert wait_for(worker1) == [worker2, worker3]

    workers = [worker2, worker3, worker1]
    send worker1, {:calculate, workers, self()}
    assert wait_for(worker1) == [worker3, worker2]
  end

  test "Four processes have each have two neighbours" do
    worker1 = spawn __MODULE__, :test_worker, []
    worker2 = spawn __MODULE__, :dummy_worker, []
    worker3 = spawn __MODULE__, :dummy_worker, []
    worker4 = spawn __MODULE__, :dummy_worker, []

    workers = [worker1, worker2, worker3, worker4]
    send worker1, {:calculate, workers, self()}
    assert wait_for(worker1) == [worker4, worker2]

    workers = [worker2, worker1, worker3, worker4]
    send worker1, {:calculate, workers, self()}
    assert wait_for(worker1) == [worker2, worker3]

    workers = [worker2, worker3, worker1, worker4]
    send worker1, {:calculate, workers, self()}
    assert wait_for(worker1) == [worker3, worker4]

    workers = [worker2, worker3, worker4, worker1]
    send worker1, {:calculate, workers, self()}
    assert wait_for(worker1) == [worker4, worker2]
  end

end
