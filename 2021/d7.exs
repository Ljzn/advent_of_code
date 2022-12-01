inputs = File.read!("inputs/d7.dat")
test_inputs = File.read!("inputs/d7-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def sol(list) do
    p =
      list
      |> Enum.sort()
      |> Enum.at(div(length(list), 2))

    list
    |> Enum.map(fn x -> abs(x - p) end)
    |> Enum.sum()
  end
end

test_expect = 37

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
