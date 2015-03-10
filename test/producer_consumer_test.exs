defmodule ProducerConsumerTest do
  use ExUnit.Case, async: true

  setup do
    :global.register_name(:manager, self)
    on_exit fn->
      :global.unregister_name(:manager)
    end
    :ok
  end

  test "the consumer will consume a value" do
    {:ok, consumer} = Consumer.start_link
    GenServer.cast(consumer, {:work, self, 5})
    assert_receive {:"$gen_cast", {:consumer_ready, ^consumer}}
  end

  test "the producer will produce a value" do
    {:ok, producer} = Producer.start_link
    GenServer.cast(producer, {:produce, self})
    assert_receive {:"$gen_cast", {:produce, value, ^producer}}
  end

end
