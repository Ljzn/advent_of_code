defmodule Scratchcards do
  def main(input) do
    parse(input)
    |> Enum.map(&points/1)
    |> Enum.sum()
  end

  def main2(input) do
    card_map =
      parse(input)
      |> Enum.map(fn card -> {card.id, %{n: 1, m: matching_numbers(card)}} end)
      |> Enum.into(%{})

    max_id = map_size(card_map)

    1..max_id//1
    |> Enum.reduce(card_map, fn id, map ->
      %{n: n, m: m} = map[id]

      (id + 1)..(id + m)//1
      |> Enum.reduce(map, fn id1, map ->
        %{map | id1 => %{m: map[id1].m, n: map[id1].n + n}}
      end)
    end)
    |> Map.values()
    |> Enum.map(& &1.n)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [id, lw, lh] = String.split(line, ["Card ", ": ", "| "], trim: true)

      %{
        id: String.trim(id) |> String.to_integer(),
        lw: String.split(lw, " ", trim: true) |> Enum.map(&String.to_integer/1),
        lh: String.split(lh, " ", trim: true) |> Enum.map(&String.to_integer/1)
      }
    end)
  end

  defp points(card) do
    matching_numbers(card)
    |> then(fn
      s when s > 0 ->
        2 ** (s - 1)

      0 ->
        0
    end)
  end

  defp matching_numbers(%{lh: lh, lw: lw}) do
    MapSet.new(lh)
    |> MapSet.intersection(MapSet.new(lw))
    |> MapSet.size()
  end
end

13 =
  """
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
  """
  |> Scratchcards.main()

30 =
  """
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
  """
  |> Scratchcards.main2()

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> &Scratchcards.main/1
    "2\n" -> &Scratchcards.main2/1
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
