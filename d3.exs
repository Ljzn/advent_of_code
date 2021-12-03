inputs = File.read!("inputs/d3.dat")
test_inputs = File.read!("inputs/d3-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n")
    |> Enum.map(fn s ->
      s
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def gamma(list) do
    l = length(list)

    list
    |> Enum.zip_reduce([], fn elements, acc ->
      acc ++ [if(Enum.sum(elements) > div(l, 2), do: 1, else: 0)]
    end)
  end

  def sol(list) do
    g = gamma(list)
    e = for x <- g, do: if(x == 1, do: 0, else: 1)
    Integer.undigits(g, 2) * Integer.undigits(e, 2)
  end
end

test_expect = 198

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.puts()
