defmodule PointOfIncidence do
  def main(input) do
    parse(input)
    |> Enum.map(fn {v, h} ->
      case {mirror_index(v, 0), mirror_index(h, 0)} do
        {iv, nil} -> iv
        {nil, ih} -> 100 * ih
      end
    end)
    |> Enum.sum()
  end

  def main2(input) do
    parse(input)
    |> Enum.map(fn {v, h} ->
      case {mirror_index(v, 1), mirror_index(h, 1)} do
        {iv, nil} -> iv
        {nil, ih} -> 100 * ih
      end
    end)
    |> Enum.sum()
  end

  defp parse(input) do
    String.split(input, "\n\n", trim: true)
    |> Enum.map(fn p -> parse_p(p) end)
  end

  defp parse_p(p) do
    # horizontal
    h = String.split(p, "\n", trim: true)

    # vertical
    v =
      h
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.zip()
      |> Enum.map(fn x -> Tuple.to_list(x) |> Enum.join() end)

    {v, h}
  end

  # [1, 2, 3] [3, 2]
  # [1, 2] [2, 1, 0]
  defp diff_mirror(a, b) do
    l = min(length(a), length(b))

    Enum.take(Enum.reverse(a), l)
    |> diff(Enum.take(b, l), 0)
  end

  defp mirror_index(list, diffs) do
    1..(length(list) - 1)
    |> Enum.find(fn i ->
      {a, b} = Enum.split(list, i)
      diff_mirror(a, b) == diffs
    end)
  end

  defp diff([], [], d), do: d
  defp diff([h | t1], [h | t2], d), do: diff(t1, t2, d)

  defp diff([h1 | t1], [h2 | t2], d) when is_binary(h1) and is_binary(h2),
    do: diff(t1, t2, d + diff(String.to_charlist(h1), String.to_charlist(h2), 0))

  defp diff([h1 | t1], [h2 | t2], d) when is_integer(h1) and is_integer(h2),
    do: diff(t1, t2, d + 1)
end
|> then(fn {_, mod, _, _} -> Process.put(:mod, mod) end)

input = """
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
"""

input2 = input

r1 = 405
r2 = 400

########## COPY & PASTE FOLLOWING CODE ##########
mod = Process.get(:mod)
f1 = &mod.main/1
f2 = &mod.main2/1

^r1 = f1.(input)
^r2 = f2.(input2)

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
