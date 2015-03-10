defmodule ProducerConsumer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    unless Mix.env == :test do
      cores = :erlang.system_info(:schedulers_online)
      producers = Application.get_env(:producer_consumer, :producers)
      consumers = Application.get_env(:producer_consumer, :consumers) || cores
      producer_children = (1..producers) |> Enum.map(fn(i)-> worker(Producer, [], id: "#{node}-Producer-#{i}") end)

      consumer_children = (1..consumers) |> Enum.map(fn(i)-> worker(Consumer, [], id: "#{node}-Consumer-#{i}") end)

      children = [ worker(Manager, [nil], id: "Manager") | (consumer_children ++ producer_children) ]
    end
    
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: ProducerConsumer.Supervisor]
    Supervisor.start_link(children || [], opts)
  end

end
