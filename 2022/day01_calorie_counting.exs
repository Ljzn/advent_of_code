defmodule CalorieCounting do
  def parse(str, :calorie) do
    String.to_integer(str)
  end

  def parse(str, :calories) do
    String.split(str, "\n", trim: true)
    |> Enum.map(&parse(&1, :calorie))
  end

  def parse(str, :elves) do
    String.split(str, "\n\n", trim: true)
    |> Enum.map(&parse(&1, :calories))
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> CalorieCounting.parse(:elves)
    |> Enum.map(fn calories -> Enum.sum(calories) end)
    |> Enum.max()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> CalorieCounting.parse(:elves)
    |> Enum.map(fn calories -> Enum.sum(calories) end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(3)
    |> Enum.sum()
    |> IO.puts()
end
