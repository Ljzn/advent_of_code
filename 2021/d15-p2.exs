inputs = File.read!("inputs/d15.dat")
test_inputs = File.read!("inputs/d15-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
      |> Enum.map(fn c -> c - ?0 end)
    end)
  end

  def sol(grid) do
    map =
      for {line, y} <- grid |> Enum.with_index() do
        for {v, x} <- line |> Enum.with_index() do
          {{x, y}, v}
        end
      end
      |> List.flatten()
      |> Enum.into(%{})

    map = expand(map)

    run(map)
  end

  def expand(map) do
    {{mx, my}, _} = Enum.max(map)
    sx = mx + 1
    sy = my + 1

    map =
      for {{x, y}, v} <- map do
        for a <- 0..4 do
          {{x + a * sx, y}, nine(v + a)}
        end
      end
      |> List.flatten()

    map =
      for {{x, y}, v} <- map do
        for a <- 0..4 do
          {{x, y + a * sy}, nine(v + a)}
        end
      end
      |> List.flatten()

    map = map |> Enum.into(%{})
    {last, _} = Enum.max(map)
    Map.put(map, :last, last)
  end

  defp nine(n) do
    x = rem(n, 9)

    if x == 0 do
      9
    else
      x
    end
  end

  defp run(map) do
    explore(map, [%{position: {0, 0}, risk: 0}], 0, MapSet.new([{0, 0}]))
  end

  defp explore(map, caves, r, visited) do
    IO.inspect(caves)
    r = r + 1

    caves =
      for %{position: p, risk: risk} <- caves do
        risk = risk + 1

        if risk == map[p] do
          adjusts(p)
          |> Enum.filter(&map[&1])
          |> Enum.reject(&MapSet.member?(visited, &1))
          |> Enum.map(fn x -> %{position: x, risk: 0} end)
        else
          %{position: p, risk: risk}
        end
      end
      |> List.flatten()
      |> Enum.uniq()

    visited =
      for %{position: p} <- caves, reduce: visited do
        acc -> MapSet.put(acc, p)
      end

    if caves |> Enum.find(fn x -> x.position == map.last and x.risk == map[map.last] - 1 end) do
      r + 1 - map[{0, 0}]
    else
      explore(map, caves, r, visited)
    end
  end

  defp adjusts({x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
  end
end

test_expect = 315

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

# raise("test passed")

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
