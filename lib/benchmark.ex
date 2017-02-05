defmodule Benchmark do

@logfile "benchmark_results.txt"

  @moduledoc """
  Performs basic benchmarking activities, i.e. running the TSP algorithms
  multiple times, saving the timing results to log file.
  """

  @algorithm &MasterSlave.Tsp.run/0

  # Measures the time taken to execute the given function.

  defp measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end

  # Log the test run details to file.

  def log_to_file(duration, run, file) do
      {{year, month, day}, {hour, mins, secs}} = :calendar.local_time
      time_info = "(#{day}/#{month}/#{year} #{hour}:#{pad(mins)}:#{pad(secs)})"
      text = "Run #{pad(run)}: #{time_info} The algorithm ran in #{duration} seconds."
      IO.puts(text)
      IO.puts(file, text)
  end

  defp pad(number) do
    number
    |> Integer.to_string
    |> String.pad_leading(2, "0")
  end

  @doc """
  Executes the measure function the number of times given by count.
  """
  def run(count \\ 30) do
    {:ok, file} = File.open(@logfile, [:read, :utf8, :append])

    for run <- 1..count do
      measure(@algorithm)
      |> log_to_file(run, file)
    end

    File.close(file)
  end

end
