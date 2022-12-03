defmodule RucksackReorganization do
  def parse(str, :rucksacks) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse(&1, :rucksack))
  end

  def parse(str, :rucksack) do
    str
    |> String.to_charlist()
    |> Enum.map(fn x ->
      cond do
        x in ?a..?z -> x - ?a + 1
        x in ?A..?Z -> x - ?A + 27
      end
    end)
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> RucksackReorganization.parse(:rucksacks)
    |> Enum.map(fn r ->
      l = length(r)
      [p1, p2] = Enum.chunk_every(r, div(l, 2))

      Enum.find(p1, fn x -> x in p2 end)
    end)
    |> Enum.sum()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> RucksackReorganization.parse(:rucksacks)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [p1, p2, p3] ->
      Enum.find(p1, fn x -> x in p2 and x in p3 end)
    end)
    |> Enum.sum()
    |> IO.puts()
end
