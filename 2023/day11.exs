defmodule CosmicExpansion do
  def main(input) do
    main2(input, 2)
  end

  def main2(input, times) do
    %{g: galaxies} = read(String.to_charlist(input), %{row: 0, col: 0, g: []})

    {row_size, col_size} = expand(galaxies, times)

    pairs(galaxies)
    |> Enum.map(&distance(&1, row_size, col_size))
    |> Enum.sum()
  end

  defp read([], m), do: m
  defp read([?\n | t], m), do: read(t, %{m | row: m.row + 1, col: 0})
  defp read([?. | t], m), do: read(t, %{m | col: m.col + 1})
  defp read([?# | t], m), do: read(t, %{m | col: m.col + 1, g: [{m.row, m.col} | m.g]})

  defp expand(galaxies, times) do
    {rows, cols} = Enum.unzip(galaxies)
    {expands(rows, times), expands(cols, times)}
  end

  defp expands(list, times) do
    Enum.min(list)..Enum.max(list)
    |> Enum.reject(fn i -> MapSet.member?(MapSet.new(list), i) end)
    |> Enum.map(fn i -> {i, times} end)
    |> Enum.into(%{})
  end

  defp pairs([]), do: []

  defp pairs([h | t]) do
    for x <- t do
      {h, x}
    end ++ pairs(t)
  end

  defp distance({{r1, c1}, {r2, c2}}, row_size, col_size) do
    f = fn a1, a2, s ->
      (for(a <- a1..a2, do: s[a] || 1)
       |> Enum.sum()) - 1
    end

    f.(r1, r2, row_size) + f.(c1, c2, col_size)
  end
end
|> then(fn {_, mod, _, _} -> Process.put(:mod, mod) end)

input = """
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
"""

input2 = input

r1 = 374
r2 = 8410

########## COPY & PASTE FOLLOWING CODE ##########
mod = Process.get(:mod)
f1 = &mod.main/1
f2 = &mod.main2(&1, 100)

^r1 = f1.(input)
^r2 = f2.(input2)

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> f1
    "2\n" -> &mod.main2(&1, 1_000_000)
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
