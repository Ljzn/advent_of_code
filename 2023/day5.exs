defmodule Fertilizer do
  def main(input) do
    %{seeds: seeds, maps: maps} = parse(input)

    Enum.reduce(maps, seeds, fn map, seeds ->
      Enum.map(seeds, fn seed ->
        convert(map.data, seed)
      end)
    end)
    |> Enum.min()
  end

  def main2(input) do
    %{seeds: seeds, maps: maps} = parse(input)

    Enum.reduce(maps, Enum.chunk_every(seeds, 2) |> Enum.map(fn [a, b] -> {a, b} end), fn map,
                                                                                          seeds ->
      convert_ranges(map.data, seeds)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
  end

  defp parse(input) do
    String.split(input, "\n\n", trim: true)
    |> Enum.map(fn line ->
      [h | t] = String.split(line, [":", "\n"], trim: true)

      %{
        name: h,
        data:
          t
          |> Enum.map(fn l ->
            String.split(l, " ", trim: true) |> Enum.map(&String.to_integer/1)
          end)
      }
    end)
    |> then(fn [seeds | maps] ->
      %{
        seeds: seeds.data |> hd(),
        maps: maps
      }
    end)
  end

  defp convert([[dest, sour, r] | _t], seed) when seed >= sour and seed < sour + r do
    seed - sour + dest
  end

  defp convert([_ | t], seed), do: convert(t, seed)
  defp convert([], seed), do: seed

  defp convert_ranges([], seeds), do: seeds

  defp convert_ranges([h | t], seeds) do
    {remain, converted} =
      Enum.map(seeds, &convert_range(h, &1))
      |> Enum.unzip()

    remain = List.flatten(remain)
    converted = List.flatten(converted)

    converted ++ convert_ranges(t, remain)
  end

  defp convert_range([dest, sour, r], {s, len}) do
    # converter: l1..r1
    # seed: l2..r2
    l1 = sour
    r1 = sour + r - 1
    l2 = s
    r2 = s + len - 1

    if max(l1, l2) <= min(r1, r2) do
      remain = [{l2, l1 - l2}, {r1 + 1, r2 - r1}] |> Enum.reject(fn {_s, len} -> len <= 0 end)

      converted = [
        {
          max(l1, l2) - sour + dest,
          min(r1, r2) - max(l1, l2) + 1
        }
      ]

      {remain, converted}
    else
      {[{s, len}], []}
    end
  end
end

input = """
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""

35 = Fertilizer.main(input)
46 = Fertilizer.main2(input)

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> &Fertilizer.main/1
    "2\n" -> &Fertilizer.main2/1
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
