defmodule RegolithReservoir do
  def parse(str, :paths) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse(&1, :path))
  end

  def parse(str, :path) do
    str
    |> String.split(" -> ", trim: true)
    |> Enum.map(&parse(&1, :point))
  end

  def parse(str, :point) do
    str
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> then(fn [x, y] -> {x, y} end)
  end

  def add_paths(map, paths) do
    map =
      Enum.reduce(paths, map, fn path, acc ->
        add_path(acc, path)
      end)

    lowest = List.flatten(paths) |> Enum.map(fn {_, y} -> y end) |> Enum.max()
    Map.put(map, :lowest, lowest)
  end

  defp add_path(map, [{x1, y1}, {x2, y2} = p2 | t]) do
    map =
      for x <- x1..x2, y <- y1..y2 do
        {x, y}
      end
      |> Enum.reduce(map, fn p, acc -> Map.put(acc, p, "#") end)

    add_path(map, [p2 | t])
  end

  defp add_path(map, _), do: map

  def sand_down(map, {x, y} \\ {500, 0}) do
    # IO.inspect({x, y})

    cond do
      y + 1 > map.lowest ->
        Map.put(map, :abyss, true)

      map[{x, y + 1}] == nil ->
        sand_down(map, {x, y + 1})

      map[{x - 1, y + 1}] == nil ->
        sand_down(map, {x - 1, y + 1})

      map[{x + 1, y + 1}] == nil ->
        sand_down(map, {x + 1, y + 1})

      true ->
        map
        |> Map.put({x, y}, "o")
        |> sand_down()
    end
  end

  def sand_down2(map, {x, y} \\ {500, 0}) do
    print(map, {x, y})

    cond do
      y == map.lowest + 1 ->
        map
        |> Map.put({x, y}, "o")
        |> sand_down2()

      map[{x, y + 1}] == nil ->
        sand_down2(map, {x, y + 1})

      map[{x - 1, y + 1}] == nil ->
        sand_down2(map, {x - 1, y + 1})

      map[{x + 1, y + 1}] == nil ->
        sand_down2(map, {x + 1, y + 1})

      true ->
        map = map |> Map.put({x, y}, "o")

        if y == 0 do
          map
        else
          map
          |> sand_down2()
        end
    end
  end

  defp print(map, sand) do
    map = Map.put(map, sand, "o")
    x0 = 450
    x1 = 550
    y0 = 0
    y1 = 50

    [
      for {y, i} <- y0..y1 |> Enum.with_index() do
        [
          for x <- x0..x1 do
            (map[{x, y}] || ".")
            |> case do
              "." -> [IO.ANSI.light_blue(), ".", IO.ANSI.reset()]
              "o" -> [IO.ANSI.light_yellow(), "o", IO.ANSI.reset()]
              "#" -> [IO.ANSI.light_black(), "#", IO.ANSI.reset()]
            end
          end,
          to_string(i),
          "\n"
        ]
      end,
      IO.ANSI.cursor_up(y1 - y0 + 1)
    ]
    |> IO.write()
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> RegolithReservoir.parse(:paths)
    |> then(fn paths -> RegolithReservoir.add_paths(%{}, paths) end)
    |> RegolithReservoir.sand_down()
    |> Map.values()
    |> Enum.count(fn x -> x == "o" end)
    |> inspect()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> RegolithReservoir.parse(:paths)
    |> then(fn paths -> RegolithReservoir.add_paths(%{}, paths) end)
    |> RegolithReservoir.sand_down2()
    |> Map.values()
    |> Enum.count(fn x -> x == "o" end)
    |> inspect()
    |> IO.puts()
end
