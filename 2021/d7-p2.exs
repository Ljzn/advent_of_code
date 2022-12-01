inputs = File.read!("inputs/d7.dat")
test_inputs = File.read!("inputs/d7-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @max 2000

  def sol(list) do
    fib = fib_store(1, @max, %{0 => 0})

    for x <- 0..(@max - 1) do
      for i <- list do
        fib[abs(x - i)]
      end
      |> Enum.sum()
    end
    |> Enum.min()
  end

  defp fib_store(x, x, s), do: s

  defp fib_store(x, e, s) do
    fib_store(x + 1, e, Map.put(s, x, s[x - 1] + x))
  end
end

test_expect = 168

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
