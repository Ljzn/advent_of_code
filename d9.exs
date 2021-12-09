inputs = File.read!("inputs/d9.dat")
test_inputs = File.read!("inputs/d9-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
      |> Enum.map(fn c -> c - ?0 end)
    end)
  end

  def sol(grid) do
    t = :ets.new(:grid, [:set])

    for {line, y} <- grid |> Enum.with_index() do
      for {v, x} <- line |> Enum.with_index() do
        :ets.insert_new(t, {{x, y}, v})
      end
    end

    for {_, v} <- low_points(t), reduce: 0 do
      acc -> acc + v + 1
    end
  end

  defp low_points(t) do
    for {{x, y}, v} <- :ets.tab2list(t) do
      if [
           :ets.lookup(t, {x - 1, y}),
           :ets.lookup(t, {x + 1, y}),
           :ets.lookup(t, {x, y - 1}),
           :ets.lookup(t, {x, y + 1})
         ]
         |> List.flatten()
         |> Enum.all?(fn {_, v1} -> v1 > v end) do
        {{x, y}, v}
      else
        nil
      end
    end
    |> Enum.filter(& &1)
  end
end

test_expect = 15

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
