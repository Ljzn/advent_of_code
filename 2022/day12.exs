defmodule HillClimbingAlgorithm do
  @track [?^, ?v, ?<, ?>]

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
    |> Enum.map(fn s -> String.to_charlist(String.replace(s, "v", "V")) end)
    |> to_map()
  end

  def explore(map, p) do
    s = map[p]

    neighbors(p)
    |> Enum.map(fn p1 ->
      case map[p1] do
        nil ->
          nil

        s1 when s1 in @track ->
          nil

        s1 ->
          if accessable(s, s1) do
            {update_map(map, p, p1), p1}
          end
      end
    end)
    |> Enum.filter(& &1)
  end

  defp neighbors({x, y}) do
    [
      {x, y - 1},
      {x, y + 1},
      {x + 1, y},
      {x - 1, y}
    ]
  end

  defp accessable(?V, p2) when (p2 >= ?a and p2 <= ?u) or p2 == ?V or p2 == ?w, do: true
  defp accessable(?z, ?E), do: true
  defp accessable(?u, p2) when (p2 >= ?a and p2 <= ?u) or p2 == ?V, do: true
  defp accessable(?S, ?a), do: true
  defp accessable(p1, p2) when p2 >= ?a and p2 <= ?z and p2 <= p1 + 1, do: true
  defp accessable(_, _), do: false

  defp update_map(map, {x0, y0}, {x1, y1}) do
    s =
      case {x1 - x0, y1 - y0} do
        {0, 1} -> ?v
        {0, -1} -> ?^
        {1, 0} -> ?>
        {-1, 0} -> ?<
      end

    Map.put(map, {x0, y0}, s)
  end

  def bfs(q, mins) do
    # :queue.to_list(q) |> IO.inspect()
    {{:value, {map, p}}, q} = :queue.out(q)
    print(map)
    steps = count_steps(map)

    cond do
      map[p] == ?E ->
        steps

      mins[p] == nil or mins[p] > steps ->
        mins = Map.put(mins, p, steps)

        explore(map, p)
        |> :queue.from_list()
        |> then(fn q1 -> :queue.join(q, q1) end)
        |> bfs(mins)

      mins[p] <= steps ->
        bfs(q, mins)
    end
  end

  defp count_steps(map) do
    Enum.count(map, fn {_, v} -> v in @track end)
  end

  defp print(map) do
    kvs =
      map
      |> Enum.map(fn {{x, y}, v} -> {{y, x}, v} end)
      |> Enum.sort()

    line_length = Enum.count(kvs, fn {{y, _}, _} -> y == 0 end)
    lines = Enum.count(kvs, fn {{_, x}, _} -> x == 0 end)

    IO.write(IO.ANSI.cursor_up(lines))

    kvs
    |> Enum.chunk_every(line_length)
    |> Enum.map(fn line ->
      Enum.map(line, fn {_, v} -> v end) |> to_string()
    end)
    |> Enum.join("\n")
    |> String.replace(~w(^ v < >), fn x -> IO.ANSI.red() <> x <> IO.ANSI.reset() end)
    |> IO.puts()
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> HillClimbingAlgorithm.parse()
    |> then(fn map ->
      HillClimbingAlgorithm.bfs(
        :queue.from_list([{map, Enum.find(map, fn {_, v} -> v == ?S end) |> elem(0)}]),
        %{}
      )
    end)
    |> inspect()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> HillClimbingAlgorithm.parse()
    |> then(fn map ->
      HillClimbingAlgorithm.bfs(
        :queue.from_list(
          Enum.filter(map, fn {_, v} -> v == ?S or v == ?a end)
          |> Enum.map(fn {p, _} -> {map, p} end)
        ),
        %{}
      )
    end)
    |> inspect()
    |> IO.puts()
end
