defmodule CampCleanup do
  def fully_contains([l1, r1], [l2, r2]) do
    l1 <= l2 and r1 >= r2
  end

  def overlapping([l1, r1], [l2, r2]) do
    not (l1 > r2 or r1 < l2)
  end

  def parse(str, :pairs) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse(&1, :pair))
  end

  def parse(str, :pair) do
    str
    |> String.split(",", trim: true)
    |> Enum.map(&parse(&1, :range))
  end

  def parse(str, :range) do
    str
    |> String.split("-", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> CampCleanup.parse(:pairs)
    |> Enum.count(fn [a, b] ->
      CampCleanup.fully_contains(a, b) or CampCleanup.fully_contains(b, a)
    end)
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> CampCleanup.parse(:pairs)
    |> Enum.count(fn [a, b] ->
      CampCleanup.overlapping(a, b)
    end)
    |> IO.puts()
end
