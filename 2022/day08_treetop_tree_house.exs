defmodule TreetopTreeHouse do
  def to_map(rows) do
    rows
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {t, x} ->
        {{x, y}, t}
      end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end

  def parse(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn s -> String.split(s, "", trim: true) |> Enum.map(&String.to_integer/1) end)
    |> to_map()
  end

  def see_from(map, saw, p, d) do
    saw = MapSet.put(saw, p)

    case find(map, p, d, fn h -> h > map[p] end) do
      nil -> saw
      p1 -> see_from(map, saw, p1, d)
    end
  end

  defp find(map, p, d, c) do
    p1 = next(p, d)

    cond do
      map[p1] == nil ->
        nil

      c.(map[p1]) ->
        p1

      true ->
        find(map, p1, d, c)
    end
  end

  defp next({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  def count_visible(map) do
    {{mx, my}, _} = Enum.max(map)

    [
      {fn {x, _y} -> x == 0 end, {1, 0}},
      {fn {_x, y} -> y == 0 end, {0, 1}},
      {fn {x, _y} -> x == mx end, {-1, 0}},
      {fn {_x, y} -> y == my end, {0, -1}}
    ]
    |> Enum.map(fn {filter, d} ->
      map
      |> Map.keys()
      |> Enum.filter(filter)
      |> Enum.map(fn p -> {p, d} end)
    end)
    |> List.flatten()
    |> Enum.reduce(MapSet.new(), fn {p, d}, acc ->
      see_from(map, acc, p, d)
    end)
    |> MapSet.size()
  end

  def scenic_score(map, p) do
    [
      {1, 0},
      {0, 1},
      {-1, 0},
      {0, -1}
    ]
    |> Enum.map(fn d ->
      case find(map, p, d, fn h -> h >= map[p] end) do
        nil ->
          distance_to_edge(map, p, d)

        p1 ->
          distance(p, p1)
      end
    end)
    # |> IO.inspect(label: inspect(p))
    |> Enum.reduce(1, fn a, b -> a * b end)
  end

  defp distance({x, y1}, {x, y2}), do: abs(y1 - y2)
  defp distance({x1, y}, {x2, y}), do: abs(x1 - x2)

  defp distance_to_edge(map, p, d, s \\ 0) do
    p1 = next(p, d)

    case map[p1] do
      nil ->
        s

      _ ->
        distance_to_edge(map, p1, d, s + 1)
    end
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> TreetopTreeHouse.parse()
    |> TreetopTreeHouse.count_visible()
    |> inspect()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> TreetopTreeHouse.parse()
    |> then(fn map ->
      map
      |> Map.keys()
      |> Enum.map(fn p ->
        TreetopTreeHouse.scenic_score(map, p)
      end)
    end)
    |> Enum.max()
    |> IO.puts()
end
