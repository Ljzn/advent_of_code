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
      {:corrupted, h} -> point(h)
      _ -> 0
    end)
    |> Enum.sum()
  end

  @left [?(, ?[, ?{, ?<]
  @right [?), ?], ?}, ?>]

  def check([], []), do: :complete
  def check([], _), do: :incomplete

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

  defp point(?)), do: 3
  defp point(?]), do: 57
  defp point(?}), do: 1197
  defp point(?>), do: 25137

  defp right(?(), do: ?)
  defp right(?[), do: ?]
  defp right(?{), do: ?}
  defp right(?<), do: ?>

  defp head([h | _]), do: h
  defp head([]), do: nil
end

test_expect = 26397

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
