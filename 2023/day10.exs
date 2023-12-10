defmodule PipeMaze do
  def main(input) do
    {coords, start} = parse(input)
    bfs(coords, [start], -1, ?.) |> elem(1)
  end

  def main2(input, print?) do
    {coords, start} = parse(input)

    coords
    |> bfs([start], -1, ?x)
    |> elem(0)
    |> clean(coords)
    |> zoom_in()
    |> flood(print?)
    |> Enum.count(fn {_, c} -> c == ?. end)
  end

  defp clean(new_c, old_c) do
    Map.merge(new_c, old_c, fn _k, new_v, old_v ->
      cond do
        new_v in ~c(J L 7 F | -) -> ?.
        true -> old_v
      end
    end)
  end

  defp parse(input) do
    coords =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.map(fn {c, x} -> {{x, y}, c} end)
        |> Enum.into(%{})
        |> Map.merge(acc)
      end)

    {coords, Enum.find(coords, fn {_coord, c} -> c == ?S end) |> elem(0)}
  end

  defp connect(?S), do: [:up, :down, :left, :right]
  defp connect(?7), do: [:left, :down]
  defp connect(?-), do: [:left, :right]
  defp connect(?F), do: [:down, :right]
  defp connect(?L), do: [:up, :right]
  defp connect(?J), do: [:up, :left]
  defp connect(?|), do: [:up, :down]
  defp connect(c) when c in [?., ?x, ?^], do: []

  defp foresee(:up), do: fn {x, y} -> {{x, y - 1}, :down} end
  defp foresee(:down), do: fn {x, y} -> {{x, y + 1}, :up} end
  defp foresee(:left), do: fn {x, y} -> {{x - 1, y}, :right} end
  defp foresee(:right), do: fn {x, y} -> {{x + 1, y}, :left} end

  defp bfs(coords, [], step, _mark), do: {coords, step}

  defp bfs(coords, pipes, step, mark) do
    pipes1 =
      pipes
      |> Enum.flat_map(fn pipe ->
        coords[pipe]
        |> connect()
        |> Enum.map(fn d ->
          {pipe1, d1} = foresee(d).(pipe)

          if coords[pipe1] && d1 in connect(coords[pipe1]) do
            pipe1
          else
            nil
          end
        end)
        |> Enum.filter(& &1)
      end)

    bfs(
      mark_points(coords, pipes, mark),
      pipes1,
      step + 1,
      mark
    )
  end

  defp mark_points(coords, points, mark) do
    coords |> Map.merge(points |> Enum.map(fn p -> {p, mark} end) |> Enum.into(%{}))
  end

  defp flood(coords, print?) do
    {max_x, max_y} =
      coords
      |> Map.keys()
      |> Enum.max()

    starts =
      List.flatten(
        for(x <- 0..max_x, do: [{x, 0}, {x, max_y}]) ++
          for(y <- 0..max_y, do: [{0, y}, {max_x, y}])
      )

    do_flood(coords, starts, print?)
  end

  defp do_flood(coords, [], _), do: coords

  defp do_flood(coords, starts, print?) do
    if print? do
      print(coords)
    end

    starts =
      Enum.filter(starts, fn xy ->
        coords[xy] && coords[xy] in ~c(^ .)
      end)

    coords
    |> mark_points(starts, ?x)
    |> do_flood(Enum.flat_map(starts, &adjusts/1), print?)
  end

  defp adjusts({x, y}),
    do: [
      {x, y + 1},
      {x, y - 1},
      {x + 1, y},
      {x - 1, y}
    ]

  defp print(coords) do
    :timer.sleep(150)
    IO.ANSI.clear()

    coords
    |> Enum.group_by(fn {{_x, y}, _c} -> y end)
    |> Enum.sort()
    |> Enum.map(fn {_, line} ->
      [
        Enum.sort(line)
        |> Enum.map(fn {_, c} -> c end)
        | "\n"
      ]
    end)
    |> IO.iodata_to_binary()
    |> String.replace("x", IO.ANSI.blue() <> "x" <> IO.ANSI.reset())
    |> IO.puts()
  end

  defp zoom_in(coords) do
    coords
    # plant grass at right side of pipe
    |> Enum.flat_map(fn {{x, y}, c} ->
      left = {2 * x, y}
      right = {2 * x + 1, y}

      case c do
        c when c in ~c(| J 7) -> [{left, c}, {right, ?^}]
        c when c in ~c(- L F S) -> [{left, c}, {right, ?-}]
        c when c in ~c(. ^) -> [{left, c}, {right, ?^}]
      end
    end)
    # plant grass at up side of pipe
    |> Enum.flat_map(fn {{x, y}, c} ->
      up = {x, 2 * y}
      down = {x, 2 * y + 1}

      case c do
        c when c in ~c(| J L S) -> [{down, c}, {up, ?|}]
        c when c in ~c(- 7 F) -> [{down, c}, {up, ?^}]
        c when c in ~c(. ^) -> [{down, c}, {up, ?^}]
      end
    end)
    |> Enum.into(%{})
  end
end
|> then(fn {_, mod, _, _} -> Process.put(:mod, mod) end)

input = """
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
"""

input2 = """
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
"""

r1 = 8
r2 = 10

########## COPY & PASTE FOLLOWING CODE ##########
mod = Process.get(:mod)
f1 = &mod.main/1
f2 = &mod.main2/2

^r1 = f1.(input)
^r2 = f2.(input2, true)

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> f1
    "2\n" -> fn x -> f2.(x, false) end
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
