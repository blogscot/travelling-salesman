defmodule Benchmark do

@logfile "seq_logfile"

  @doc """
  Runs and displays the time taken for  the TSP algorithm.
  """

  def measure(file) do
    (fn -> Tsp.run end)
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
    |> (fn duration ->
      {{year, month, day}, {hour, mins, secs}} = :calendar.local_time
      text = "#{day}/#{month}/#{year} #{hour}:#{pad(mins)}:#{pad(secs)} The algorithm ran in #{duration} seconds."
      IO.puts(text)
      IO.puts(file, text)
    end).()
  end

  @doc """
  Executes the measure function the number of times given by count.
  """

  def run(count \\ 1) do

    {:ok, file} = File.open(@logfile, [:read, :utf8, :append])
    for _ <- 1..count, do: measure(file)
    File.close(file)
  end

  defp pad(number) when number < 10, do: "0" <> Integer.to_string(number)
  defp pad(number), do: number

end
