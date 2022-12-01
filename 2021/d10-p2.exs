inputs = File.read!("inputs/d10.dat")
test_inputs = File.read!("inputs/d10-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
    end)
  end

  def sol(lines) do
    lines
    |> Enum.map(fn l -> check(l, []) end)
    |> Enum.map(fn
      {:incomplete, m} ->
        score(m, 0)

      _ ->
        nil
    end)
    |> Enum.filter(& &1)
    |> Enum.sort()
    |> then(fn x -> Enum.sort(x) |> Enum.at(length(x) |> div(2)) end)
  end

  @left [?(, ?[, ?{, ?<]
  @right [?), ?], ?}, ?>]

  def check([], []), do: :complete
  def check([], m), do: {:incomplete, m}

  def check([h | t], m) do
    h1 = head(m)

    case h do
      ^h1 ->
        check(t, tl(m))

      h when h in @left ->
        check(t, [right(h) | m])

      h ->
        {:corrupted, h}
    end
  end

  def score([], s), do: s
  def score([h | t], s), do: score(t, s * 5 + point(h))

  defp point(?)), do: 1
  defp point(?]), do: 2
  defp point(?}), do: 3
  defp point(?>), do: 4

  defp right(?(), do: ?)
  defp right(?[), do: ?]
  defp right(?{), do: ?}
  defp right(?<), do: ?>

  defp head([h | _]), do: h
  defp head([]), do: nil
end

test_expect = 288_957

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
