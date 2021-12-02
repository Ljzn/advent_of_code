inputs = File.read!("inputs/d1.dat")
test_inputs = File.read!("inputs/d1-test.dat")

defmodule S do
  def pre(str) do
    str |> String.split() |> Enum.map(&String.to_integer/1)
  end

  def cmp([a, b | t], n) when a < b do
    cmp([b | t], n + 1)
  end

  def cmp([_ | t], n), do: cmp(t, n)

  def cmp(_, n), do: n

  def sol(list), do: cmp(list, 0)
end

test_expect = 7

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.puts()
