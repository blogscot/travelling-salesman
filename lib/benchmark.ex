defmodule Benchmark do

@logfile "benchmark_results.txt"

  @moduledoc """
  Performs basic benchmarking activities, i.e. running the TSP algorithms
  multiple times, saving the timing results to log file.
  """

  @doc """
  Runs and displays the time taken for  the TSP algorithm.
  """

  def measure(run, file) do
    (fn -> Cellular.Tsp.run end)
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
    |> (fn duration ->
      {{year, month, day}, {hour, mins, secs}} = :calendar.local_time
      text = "Run #{run}: (#{day}/#{month}/#{year} #{hour}:#{pad(mins)}:#{pad(secs)}) The algorithm ran in #{duration} seconds."
      IO.puts(text)
      IO.puts(file, text)
    end).()
  end

  @doc """
  Executes the measure function the number of times given by count.
  """

  def run(count \\ 1) do

    {:ok, file} = File.open(@logfile, [:read, :utf8, :append])
    for run <- 1..count, do: measure(run, file)
    File.close(file)
  end

  defp pad(number) when number < 10, do: "0" <> Integer.to_string(number)
  defp pad(number), do: number

end
