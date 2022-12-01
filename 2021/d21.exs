# test
# Player 1 starting position: 4
# Player 2 starting position: 8

# input
# Player 1 starting position: 4
# Player 2 starting position: 2

defmodule S do
  def sol(p1, p2) do
    1..100
    |> Stream.cycle()
    |> Stream.chunk_every(3)
    |> Stream.map(fn x -> Enum.sum(x) end)
    |> Stream.chunk_every(2)
    |> Enum.flat_map_reduce(
      %{p1: %{dice: 0, score: 0, pos: p1}, p2: %{dice: 0, score: 0, pos: p2}, last: nil},
      fn [p1_step, p2_step], acc ->
        acc = %{
          acc
          | p1: change(acc.p1, p1_step),
            p2: change(acc.p2, p2_step),
            last: Map.delete(acc, :last)
        }

        f1 = acc.p1.score >= 1000
        f2 = acc.p2.score >= 1000

        cond do
          f1 ->
            {:halt, acc.last.p2.score * (acc.last.p2.dice + acc.p1.dice)}

          f2 ->
            {:halt, acc.p1.score * (acc.p1.dice + acc.p2.dice)}

          true ->
            {[], acc}
        end
      end
    )
    |> elem(1)
  end

  defp change(%{dice: d, score: s, pos: p}, step) do
    p = 1..10 |> Enum.at(rem(p - 1 + step, 10))
    %{dice: d + 3, score: s + p, pos: p}
  end
end

# test
739_785 =
  S.sol(4, 8)
  |> IO.inspect(label: "test")

# p1
S.sol(4, 2)
|> IO.inspect()
