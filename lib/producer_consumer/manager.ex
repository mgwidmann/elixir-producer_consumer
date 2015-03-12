defmodule Manager do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state || %{queue: [], consumers: [], producers: []})
  end

  def init(state) do
    #                                          &:global.random_exit_name/3
    case :global.register_name(:manager, self, &always_choose_matt/3) do
      :yes ->
        IO.puts "#{inspect self}:\t[MAN] Leader"
        {:ok, state}
      :no ->
        IO.puts "#{inspect self}:\t[MAN] Slave"
        manager = :global.whereis_name(:manager)
        Process.monitor(manager)
        {:ok, manager}
    end
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, pid) do
    Process.exit(self, :normal) # Goodbye cruel world, our leader has departed
  end

  def handle_cast({:produce, value, producer_pid}, %{consumers: [worker | rest]} = state) do
    IO.puts "#{inspect self}:\t[MAN] Assigning #{value} to #{inspect worker}@#{inspect node(worker)}"
    GenServer.cast(worker, {:work, self, value})
    GenServer.cast(producer_pid, {:produce, self})
    {:noreply, Map.put(state, :consumers, rest)}
  end
  def handle_cast({:produce, value, producer_pid}, %{consumers: [], queue: queue} = state) do
    IO.puts "#{inspect self}:\t[MAN] Queuing value #{value} (#{Enum.count(queue)})"
    GenServer.cast(producer_pid, {:produce, self})
    {:noreply, Map.put(state, :queue, [value | queue])}
  end

  def handle_cast({:consumer_ready, consumer_pid}, %{queue: [value | rest]} = state) do
    IO.puts "#{inspect self}:\t[MAN] Consumer ready -- Assigning #{value} to #{inspect consumer_pid}@#{inspect node(consumer_pid)}"
    GenServer.cast(consumer_pid, {:work, self, value})
    {:noreply, Map.put(state, :queue, rest)}
  end
  def handle_cast({:consumer_ready, consumer_pid}, %{queue: [], consumers: consumers} = state) do
    IO.puts "#{inspect self}:\t[MAN] Consumer ready -- No work for #{inspect consumer_pid}@#{inspect node(consumer_pid)}"
    {:noreply, Map.put(state, :consumers, [consumer_pid | consumers])}
  end


  # Demo Tools
  def handle_cast({:producer_ready, producer_pid}, %{producers: producers} = state) do
    IO.puts "#{inspect self}:\t[MAN] Producer ready #{inspect producer_pid}@#{inspect node(producer_pid)}"
    {:noreply, Map.put(state, :producers, [producer_pid | producers])}
  end
  def handle_cast(:start, %{producers: producers} = state) do
    IO.puts "#{inspect self}:\t[MAN] Starting #{Enum.count(producers)} producers"
    Enum.each(producers, &(GenServer.cast(&1, {:produce, self})))
    {:noreply, state}
  end
  def start do
    GenServer.cast(:global.whereis_name(:manager), :start)
  end
  def consumers, do: GenServer.call(:global.whereis_name(:manager), :consumers)
  def producers, do: GenServer.call(:global.whereis_name(:manager), :producers)
  def handle_call(:consumers, _from, state), do: {:reply, state[:consumers], state}
  def handle_call(:producers, _from, state), do: {:reply, state[:producers], state}
  def always_choose_matt(:manager, pid1, pid2) do
    _choose_matt({node(pid1) |> to_string, pid1}, {node(pid2) |> to_string, pid2})
  end
  defp _choose_matt({"mattw@" <> ip, pid1}, {_, pid2}) do
    Process.exit(pid2, :kill)
    pid1
  end
  defp _choose_matt({_, pid1}, {"mattw@" <> ip, pid2}) do
    Process.exit(pid1, :kill)
    pid2
  end
  defp _choose_matt({_, pid1}, {_, pid2}), do: :global.random_exit_name(:manager, pid1, pid2)

end
