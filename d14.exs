inputs = File.read!("inputs/d14.dat")
test_inputs = File.read!("inputs/d14-test.dat")

defmodule S do
  def pre(str) do
    [a, rules] =
      str
      |> String.split("\n\n", trim: true)

    a =
      a
      |> String.split("", trim: true)

    rules =
      rules
      |> String.split("\n", trim: true)
      |> Enum.map(fn
        <<x1::binary-size(1), x2::binary-size(1)>> <> " -> " <> y ->
          {x1, x2, y}
      end)

    {a, rules}
  end

  @steps 10

  def sol({a, rules}) do
    run(a, rules, 0)
  end

  defp run(a, _, @steps) do
    v =
      a
      |> Enum.frequencies()
      |> Map.values()

    Enum.max(v) - Enum.min(v)
  end

  defp run(a, rules, s) do
    IO.inspect({s, a})
    a = insert(a, rules, [])

    run(a, rules, s + 1)
  end

  defp insert([x], _, r), do: [x | r] |> Enum.reverse()

  defp insert([x1, x2 | xs], rules, r) do
    i =
      Enum.find(rules, &match?({^x1, ^x2, _}, &1))
      |> elem(2)

    r = [i, x1 | r]
    insert([x2 | xs], rules, r)
  end
end

test_expect = 1588

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
