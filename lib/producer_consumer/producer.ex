defmodule Producer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    GenServer.cast(:global.whereis_name(:manager), {:producer_ready, self})
    :random.seed(:erlang.now)
    Process.monitor(:global.whereis_name(:manager))
    {:ok, nil}
  end

  def handle_cast({:produce, manager}, _) do
    :timer.sleep(Application.get_env(:producer_consumer, :producer_timeout)) # Need to slow producer down a bit
    value = :random.uniform(5) + 35
    IO.puts "#{inspect self}:\t[PRO] Creating value #{value}"
    GenServer.cast(manager, {:produce, value, self})
    {:noreply, nil}
  end

end
