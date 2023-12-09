defmodule MirageMaintenance do
  def main(input) do
    lines = parse(input)

    Enum.map(lines, &next/1)
    |> Enum.sum()
  end

  def main2(input) do
    lines = parse(input) |> Enum.map(&Enum.reverse/1)

    Enum.map(lines, &next/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, " ", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end

  defp next(list) do
    diff_list(list, [], [list])
    |> Enum.reduce(0, fn diff, acc ->
      List.last(diff) + acc
    end)
  end

  defp diff_list([h1, h2 | t], temp, diffs) do
    diff_list([h2 | t], [h2 - h1 | temp], diffs)
  end

  defp diff_list([_], temp, diffs) do
    if Enum.all?(temp, &(&1 == 0)) do
      diffs
    else
      list = Enum.reverse(temp)
      diff_list(list, [], [list | diffs])
    end
  end
end
|> then(fn {_, mod, _, _} -> Process.put(:mod, mod) end)

input = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""

input2 = input

r1 = 114
r2 = 2

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
