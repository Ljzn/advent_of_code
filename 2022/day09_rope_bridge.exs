defmodule RopeBridge do
  def parse(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [d, n] = String.split(line, " ", trim: true)
      {d, String.to_integer(n)}
    end)
  end

  def next({x1, y1}, {x2, y2}) do
    if abs(x1 - x2) <= 1 and abs(y1 - y2) <= 1 do
      {x2, y2}
    else
      {mid(x1, x2), mid(y1, y2)}
    end
  end

  defp mid(a, b) do
    c = (a + b) / 2

    if Float.round(c) == c do
      trunc(c)
    else
      a
    end
  end

  def update_pos(h, t, v) do
    t = next(h, t)
    IO.inspect({h, t})
    {h, t, MapSet.put(v, t)}
  end

  def move(d, n, h, t, v) do
    Enum.reduce(1..n, {h, t, v}, fn _, {h, t, v} ->
      h = move_once(h, d)
      update_pos(h, t, v)
    end)
  end

  def long_move(d, n, state, v) do
    Enum.reduce(1..n, {state, v}, fn _, {state, v} ->
      h = move_once(hd(state), d)

      [last | _] =
        rs =
        tl(state)
        |> Enum.reduce([h], fn t, [prev | _] = acc ->
          t = next(prev, t)
          [t | acc]
        end)

      {Enum.reverse(rs), MapSet.put(v, last)}
    end)
  end

  defp move_once({x, y}, "L"), do: {x - 1, y}
  defp move_once({x, y}, "R"), do: {x + 1, y}
  defp move_once({x, y}, "U"), do: {x, y + 1}
  defp move_once({x, y}, "D"), do: {x, y - 1}
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> RopeBridge.parse()
    |> Enum.reduce({{0, 0}, {0, 0}, MapSet.new()}, fn {d, n}, {h, t, v} ->
      RopeBridge.move(d, n, h, t, v)
    end)
    |> elem(2)
    |> MapSet.size()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> RopeBridge.parse()
    |> Enum.reduce({List.duplicate({0, 0}, 10), MapSet.new()}, fn {d, n}, {state, v} ->
      RopeBridge.long_move(d, n, state, v)
    end)
    |> elem(1)
    |> MapSet.size()
    |> IO.puts()
end
