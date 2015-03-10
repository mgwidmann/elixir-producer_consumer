defmodule ManagerTest do
  use ExUnit.Case, async: true

  test "the manager assigns a value to a consumer when available" do
    assert {:noreply, %{queue: []}} = Manager.handle_cast({:produce, 1, self}, %{consumers: [self], queue: []})
    me = self
    assert_received {:"$gen_cast", {:produce, ^me}} # Producer is told to continue producing
    assert_received {:"$gen_cast", {:work, ^me, 1}} # Consumer is told to work on the produced value
  end

  test "the manager queues produced values when there are no consumers" do
    assert {:noreply, %{queue: [1]}} = Manager.handle_cast({:produce, 1, self}, %{consumers: [], queue: []})
    me = self
    assert_received {:"$gen_cast", {:produce, ^me}}
  end

  test "commits suicide when the leader quits" do
    manager = spawn fn->
      Manager.handle_info({:DOWN, nil, :process, self, :test}, self)
    end
    :timer.sleep(10) # Wait for process to die
    refute Process.alive?(manager)
  end

  test "the manager assigns a value from the queue when available" do
    assert {:noreply, %{consumers: [], queue: []}} =
      Manager.handle_cast({:consumer_ready, self}, %{consumers: [], queue: [1]})
    me = self
    assert_received {:"$gen_cast", {:work, ^me, 1}}
  end

  test "the manager stores the consumer pid when the queue is empty" do
    me = self
    assert {:noreply, %{consumers: [^me], queue: []}} =
      Manager.handle_cast({:consumer_ready, self}, %{consumers: [], queue: []})
    refute_received {:"$gen_cast", {:work, ^me, 1}}
  end

end
