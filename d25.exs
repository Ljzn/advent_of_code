inputs = File.read!("inputs/d25.dat")
test_inputs = File.read!("inputs/d25-test.dat")

defmodule S do
  def read2d(str) do
    map = read_demension(str, "\n", fn s -> read1d(s) end)

    for {y, line} <- map, {x, c} <- line do
      {{x, y}, c}
    end
    |> Enum.into(%{})
  end

  def read1d(str) do
    read_demension(str, "", fn s -> s end)
  end

  defp read_demension(str, pattern, fun) do
    String.split(str, pattern, trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {s, i} ->
      {i, fun.(s)}
    end)
    |> Enum.into(%{})
  end

  def move(s, n \\ 1) do
    s1 =
      s
      |> units_move(">")
      |> units_move("v")

    if s1 |> equal(s) do
      n
    else
      move(s1, n + 1)
    end
  end

  defp equal(s1, s2) do
    state_id(s1) == state_id(s2)
  end

  defp state_id(s) do
    Enum.sort(s)
  end

  defp units_move(s, type) do
    s
    |> Enum.map(fn {{x, y}, u} ->
      if u == type do
        get_after_units(s, x, y)
      else
        nil
      end
    end)
    |> List.flatten()
    |> Enum.filter(& &1)
    |> Enum.reduce(s, fn {x, y, t}, s ->
      Map.put(s, {x, y}, t)
    end)
    |> tap(fn x -> print(x) end)
  end

  defp get_after_units(s, x, y) do
    type = s[{x, y}]

    {x1, y1} =
      case type do
        ">" ->
          find_unit(s, x + 1, y)

        "v" ->
          find_unit(s, x, y + 1)
      end

    case s[{x1, y1}] do
      "." ->
        [{x1, y1, type}, {x, y, "."}]

      u when u in ~w(> v) ->
        []
    end
  end

  defp find_unit(s, x, y) do
    cond do
      s[{x, y}] ->
        {x, y}

      s[{0, y}] ->
        {0, y}

      s[{x, 0}] ->
        {x, 0}
    end
  end

  defp print(grid) do
    for y <- 0..5 do
      for x <- 0..15 do
        case grid[{x, y}] do
          nil -> " "
          c -> c
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    |> IO.puts()

    IO.puts("\n")
  end
end

# test
S.read2d(test_inputs)
|> S.move()
|> IO.inspect()
|> tap(fn x -> 58 = x end)

# part1
S.read2d(inputs)
|> S.move()
|> IO.inspect()
