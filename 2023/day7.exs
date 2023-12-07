defmodule CamelCards do
  def main(input) do
    parse(input)
    |> Enum.map(fn %{cards: cards, bid: bid} ->
      v = {type(cards), Enum.map(cards, &value/1)}
      {v, bid}
    end)
    |> total_win()
  end

  def main2(input) do
    parse(input)
    |> Enum.map(fn %{cards: cards, bid: bid} ->
      v = {type2(cards), Enum.map(cards, &value2/1)}
      {v, bid}
    end)
    |> total_win()
  end

  defp total_win(value_and_bids) do
    value_and_bids
    |> Enum.sort()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {{_, b}, r}, acc -> r * b + acc end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [cards, bid] = String.split(line, " ", trim: true)

      %{
        cards: String.to_charlist(cards),
        bid: String.to_integer(bid)
      }
    end)
  end

  defp value(?A), do: 14
  defp value(?K), do: 13
  defp value(?Q), do: 12
  defp value(?J), do: 11
  defp value(?T), do: 10
  defp value(x) when x in ?1..?9, do: x - ?0

  defp value2(?J), do: 0
  defp value2(x), do: value(x)

  defp type(cards) do
    Enum.frequencies(cards)
    |> Map.values()
    |> Enum.sort()
    |> type_value()
  end

  defp type_value([5]), do: 9
  defp type_value([1, 4]), do: 8
  defp type_value([2, 3]), do: 7
  defp type_value([1, 1, 3]), do: 6
  defp type_value([1, 2, 2]), do: 5
  defp type_value([1, 1, 1, 2]), do: 4
  defp type_value([1, 1, 1, 1, 1]), do: 3

  defp type2(cards) do
    m = Enum.frequencies(cards)

    if num_j = m[?J] do
      m1 = m |> Map.delete(?J)

      if m1 == %{} do
        m
      else
        {k, _} = Enum.max_by(m1, fn {_k, v} -> v end)
        m1 |> Map.update!(k, &(&1 + num_j))
      end
    else
      m
    end
    |> Map.values()
    |> Enum.sort()
    |> type_value()
  end
end

input = """
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"""

r1 = 6440
r2 = 5905
mod = CamelCards

########## COPY & PASTE FOLLOWING CODE ##########

f1 = &mod.main/1
f2 = &mod.main2/1

^r1 = f1.(input)
^r2 = f2.(input)

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> f1
    "2\n" -> f2
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
