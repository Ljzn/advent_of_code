defmodule HotSprings do
  def main(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [a, b] = String.split(line, " ", trim: true)
      HotSprings.arrangements(a, b)
    end)
    |> Enum.sum()
  end

  def main2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [a, b] = String.split(line, " ", trim: true)
      a = a |> List.duplicate(5) |> Enum.join("?")
      b = b |> List.duplicate(5) |> Enum.join(",")
      HotSprings.arrangements(a, b)
    end)
    |> Enum.sum()
  end

  # :* means zero or more "."
  # :_ means one or more "."
  # interger means n "#"

  defp consume(?., [:* | t]), do: [:* | t]
  defp consume(?#, [:* | t]), do: consume(?#, t)
  defp consume(?., [h | _t]) when is_integer(h), do: false
  defp consume(?#, [h | t]) when is_integer(h) and h > 1, do: [h - 1 | t]
  defp consume(?#, [1 | t]), do: t
  defp consume(?., [:_ | t]), do: [:* | t]
  defp consume(?#, [:_ | _t]), do: false
  defp consume(_, []), do: false

  defp spec(line) do
    String.split(line, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.flat_map(fn x -> [:_, x] end)
    |> then(fn [_ | t] -> [:* | t] ++ [:*] end)
  end

  defp possible(a, b) do
    case Process.get({a, b}) do
      nil ->
        poss(a, b)
        |> tap(&Process.put({a, b}, &1))

      x ->
        x
    end
  end

  defp poss([], [:*]), do: 1
  defp poss([], _), do: 0

  defp poss([?? | t], spec) do
    [consume(?., spec), consume(?#, spec)]
    |> Enum.filter(& &1)
    |> Enum.reduce(0, fn x, acc ->
      possible(t, x) + acc
    end)
  end

  defp poss([h | t], spec) do
    case consume(h, spec) do
      false -> 0
      spec -> possible(t, spec)
    end
  end

  def arrangements(a, b) do
    a
    |> String.to_charlist()
    |> possible(spec(b))
  end
end
|> then(fn {_, mod, _, _} -> Process.put(:mod, mod) end)

input = """
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
"""

input2 = input

r1 = 21
r2 = 525_152

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
