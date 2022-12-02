defmodule RockPaperScissors do
  @rock :rock
  @paper :paper
  @scissors :scissors

  @shapes [@rock, @paper, @scissors]

  def score(shape) when shape in @shapes, do: Enum.find_index(@shapes, &(&1 == shape)) + 1

  def score(:draw), do: 3
  def score(:won), do: 6
  def score(:lost), do: 0

  def compare(x, x), do: :draw

  def compare(a, b) do
    if a == how(:won, b) do
      :won
    else
      :lost
    end
  end

  def parse(str, :shape) when str in ~w(A X), do: @rock
  def parse(str, :shape) when str in ~w(B Y), do: @paper
  def parse(str, :shape) when str in ~w(C Z), do: @scissors

  def parse("X", :goal), do: :lost
  def parse("Y", :goal), do: :draw
  def parse("Z", :goal), do: :won

  def parse(str, :round, 1) do
    String.split(str, " ", trim: true)
    |> Enum.map(&parse(&1, :shape))
  end

  def parse(str, :round, 2) do
    # parse and figure out what shape to choose so the round end as indicated
    [sa, sb] = String.split(str, " ", trim: true)
    a = parse(sa, :shape)
    b = how(parse(sb, :goal), a)
    [a, b]
  end

  def parse(str, :rounds, rule) do
    String.split(str, "\n", trim: true)
    |> Enum.map(&parse(&1, :round, rule))
  end

  def calculate_my_socre(rounds) do
    rounds
    |> Enum.map(fn [a, b] -> score(compare(b, a) |> IO.inspect()) + score(b) end)
    |> IO.inspect()
    |> Enum.sum()
  end

  def how(:draw, oppo), do: oppo

  def how(:won, oppo) do
    Enum.at(@shapes, rem(Enum.find_index(@shapes, &(&1 == oppo)) + 1, 3))
  end

  def how(:lost, oppo) do
    Enum.at(@shapes, rem(Enum.find_index(@shapes, &(&1 == oppo)) + 2, 3))
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> RockPaperScissors.parse(:rounds, 1)
    |> RockPaperScissors.calculate_my_socre()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> RockPaperScissors.parse(:rounds, 2)
    |> IO.inspect()
    |> RockPaperScissors.calculate_my_socre()
    |> IO.puts()
end
