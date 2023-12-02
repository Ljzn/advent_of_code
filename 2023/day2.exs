defmodule CubeConundrum do
  def main(input, loads \\ %{"red" => 12, "green" => 13, "blue" => 14}) do
    games = parse(input)

    Enum.filter(games, fn %{rounds: rounds} ->
      Enum.all?(rounds, fn round -> is_possible?(round, loads) end)
    end)
    |> Enum.map(& &1.game)
    |> Enum.sum()
  end

  def main2(input) do
    games = parse(input)

    games
    |> Enum.map(fn g ->
      min_loads(g.rounds, %{"red" => 0, "blue" => 0, "green" => 0})
      |> Map.values()
      |> then(fn [a, b, c] -> a * b * c end)
    end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [game_id | rounds] =
        line
        |> String.split(["Game ", ": ", "; "], trim: true)

      %{
        game: String.to_integer(game_id),
        rounds:
          Enum.map(rounds, fn round ->
            round
            |> String.split(", ", trim: true)
            |> Enum.map(fn pick ->
              [num, color] = String.split(pick, " ", trim: true)
              %{num: String.to_integer(num), color: color}
            end)
          end)
      }
    end)
  end

  defp is_possible?([], _), do: true

  defp is_possible?([%{color: color, num: num} | t], limit) do
    if limit[color] < num do
      false
    else
      is_possible?(t, limit)
    end
  end

  defp min_loads([], loads), do: loads

  defp min_loads([h | t], loads) do
    loads =
      h
      |> Enum.map(&{&1.color, &1.num})
      |> Enum.into(%{})
      |> Map.merge(loads, fn _k, v1, v2 -> max(v1, v2) end)

    min_loads(t, loads)
  end
end

8 =
  """
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  """
  |> CubeConundrum.main()

2286 =
  """
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  """
  |> CubeConundrum.main2()

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> &CubeConundrum.main/1
    "2\n" -> &CubeConundrum.main2/1
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
