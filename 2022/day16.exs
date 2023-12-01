defmodule ProboscideaVolcanium do
  def parse(str, :records) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse(&1, :record))
  end

  def parse(str, :record) do
    str
    |> String.split(
      [
        "Valve",
        "has flow rate=",
        ";",
        "tunnels",
        "tunnel",
        "lead",
        "leads",
        "to",
        "valves",
        "valve",
        ",",
        " "
      ],
      trim: true
    )
    |> then(fn [label, rate | connects] ->
      {label, String.to_integer(rate), connects}
    end)
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> ProboscideaVolcanium.parse(:records)
    |> inspect()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> inspect()
    |> IO.puts()
end
