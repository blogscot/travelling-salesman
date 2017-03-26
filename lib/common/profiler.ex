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

    # defp run_test, do: Tsp.run
    # defp run_test, do: Tsp.MasterSlave.run 2
    def run_test, do: Tsp.Island.run 2
end
 
