defmodule MigrationTest do
  use ExUnit.Case
  alias Tsp.Island

  def neighbour_process do
    receive do
      {from, elites: elites} when is_list(elites) ->
        # for testing purposes return ok message
        send from, {self(), :ok}
        neighbour_process()
    end
  end

# Waits for the neighbours results from the worker process
  test "Elite members are merged into general population" do
    population_size = 55
    elites_size = 5
    elites = Population.new(elites_size)
    population = Population.new(population_size)

    assert Island.integrate(elites, population) |> length == population_size
  end

  test "A single neighbour receives an elite migration from worker" do
    neighbour_pid = spawn __MODULE__, :neighbour_process, []
    elites_size = 5
    elites = Population.new(elites_size)

    Island.send_elites([neighbour_pid], elites)
    assert_receive({^neighbour_pid, :ok})
  end

  test "Two neighbours receive elite migrations from worker" do
    neighbour_pid1 = spawn __MODULE__, :neighbour_process, []
    neighbour_pid2 = spawn __MODULE__, :neighbour_process, []
    elites_size = 5
    elites = Population.new(elites_size)

    Island.send_elites([neighbour_pid1, neighbour_pid2], elites)

    assert_receive({^neighbour_pid1, :ok})
    assert_receive({^neighbour_pid2, :ok})
  end

  # Wrap the Island function to send a response to the test process
  def await_elites_process(sender, num_neighbours) do
    elites = Island.await_elites(num_neighbours)
    send sender, {self(), elites: elites}
  end

  test "Worker process expects migration from single neighbour" do
    awaiting_pid = spawn __MODULE__, :await_elites_process, [self(), 1]
    elites_size = 5
    elites = Population.new(elites_size)

    send awaiting_pid, {self(), elites: elites}
    assert_receive({^awaiting_pid, elites: new_elites})
    assert length(new_elites) == elites_size
  end

  test "Worker process expects migration from two neighbours" do
    num_neighbours = 2
    awaiting_pid = spawn __MODULE__, :await_elites_process, [self(), num_neighbours]
    elites_size = 5
    elites = Population.new(elites_size)

    # The function under test does not care who the sender is.
    send awaiting_pid, {self(), elites: elites}
    refute_receive({^awaiting_pid, elites: _elites}, 10)
    send awaiting_pid, {self(), elites: elites}
    assert_receive({^awaiting_pid, elites: new_elites})
    assert length(new_elites) == elites_size * num_neighbours
  end

  test "Worker process expects migration from three neighbours" do
    num_neighbours = 3
    awaiting_pid = spawn __MODULE__, :await_elites_process, [self(), num_neighbours]
    elites_size = 5
    elites = Population.new(elites_size)

    send awaiting_pid, {self(), elites: elites}
    send awaiting_pid, {self(), elites: elites}
    refute_receive({^awaiting_pid, elites: _elites}, 10)
    send awaiting_pid, {self(), elites: elites}
    assert_receive({^awaiting_pid, elites: new_elites})
    assert length(new_elites) == elites_size * num_neighbours
  end

end
