defmodule Consumer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    GenServer.cast(:global.whereis_name(:manager), {:consumer_ready, self})
    Process.monitor(:global.whereis_name(:manager))
    {:ok, nil}
  end

  def handle_cast({:work, manager, value}, _) do
    IO.puts "#{inspect self}:\t[CON] Working value #{value}"
    result = Fib.fib_reg(value)
    IO.puts "#{inspect self}:\t[CON] Result #{value} => #{result}"
    GenServer.cast(manager, {:consumer_ready, self})
    {:noreply, nil}
  end

end
