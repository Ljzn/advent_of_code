inputs = File.read!("inputs/d8.dat")
test_inputs = File.read!("inputs/d8-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split(["|", "\n"], trim: true)
    |> Enum.map(fn x ->
      x
      |> String.split(" ", trim: true)
    end)
    |> Enum.chunk_every(2)
  end

  def sol(list) do
    for [_input, output] <- list do
      output
    end
    |> List.flatten()
    |> Enum.count(fn x -> String.length(x) in [2, 4, 3, 7] end)
  end
end

test_expect = 26

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
