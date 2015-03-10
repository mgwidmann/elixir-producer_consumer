defmodule Fib do

  # Typical Fibonacci implementation
  def fib_reg(0), do: 0
  def fib_reg(1), do: 1
  def fib_reg(n) when is_number(n) and n > 0, do: fib_reg(n - 1) + fib_reg(n - 2)
  def fib_reg(_), do: {:error, "Positive numbers only"}

  # Tail Recursive implementation
  def fib(0), do: 0
  def fib(n) when is_number(n) and n > 0, do: fib(n, 1, 0, 1)
  def fib(_), do: {:error, "Positive numbers only"}

  defp fib(n, m, _prev_fib, current_fib) when n == m, do: current_fib
  defp fib(n, m, prev_fib, current_fib), do: fib(n, m+1, current_fib, prev_fib + current_fib)

end

# Try this
# 1..40 |> Enum.map(fn(i) -> Task.async fn()-> {:"#{i}", :timer.tc(Fib, :fib_reg, [i])} end end) |> Enum.map(fn(t)-> {num, {time, _}} = Task.await(t, :infinity); {num, "#{time/1000}ms"} end)
# VS
# 10_000..11_000 |> Enum.map(fn(i) -> Task.async fn()-> {:"#{i}", :timer.tc(Fib, :fib, [i])} end end) |> Enum.map(fn(t)-> {num, {time, _}} = Task.await(t, :infinity); {num, "#{time/1000}ms"} end)
