defmodule CitiesBench do
  use Benchfella

  # Is is more efficient to calcuate the city info once
  # or cache the result in a process and retrieve it using
  # messages?
  # Answer: Nope.

  # ## CitiesBench
  # benchmark name           iterations   average time 
  # Get a new set of cities      500000   6.71 µs/op
  # Get stored city info         500000   7.61 µs/op


  def setup_city_info do
    spawn __MODULE__, :get_city_info, [Cities.get_cities()]
  end

  def get_city_info(city_info) do
    receive do
      {:get_data, caller} ->
        send caller, {self(), city_info: city_info}
        get_city_info(city_info)
    end
  end

  bench "Get a new set of cities" do
    Cities.get_cities()
  end

  bench "Get stored city info", [city_pid: setup_city_info()] do
   send city_pid, {:get_data, self()}
   receive do
     {^city_pid, city_info: city_info} ->
       city_info
   end
  end

end
