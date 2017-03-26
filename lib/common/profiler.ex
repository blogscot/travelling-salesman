defmodule Profiler do
  import ExProf.Macro

  def eflame do
    :eflame.apply(&run_test/0, [])
  end

  def fprof do
    :fprof.apply(&run_test/0, [])
    :fprof.profile()
    :fprof.analyse([
      callers: true,
      sort: :own,
      totals: true,
      details: true
    ])
  end

  @doc "get analysis records and sum them up"
  def run do
    records = eprof()
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.puts "total = #{inspect total_percent}"
  end

  # "analyze with profile macro"
  defp eprof, do:
    profile do: run_test()

  # def run_test, do: Benchmark.run_island 2, false, 1
  defp run_test, do: Benchmark.run_sequential_tsp 1
end
