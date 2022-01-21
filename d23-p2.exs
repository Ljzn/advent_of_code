inputs = File.read!("inputs/d23.dat")
test_inputs = File.read!("inputs/d23-test.dat")

defmodule S do
  ## parse

  def read2d(str) do
    read_demension(str, "\n", fn s -> read1d(s) end)
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

  def read(str) do
    [l0, l1, l2, l3, l4] =
      str
      |> String.split("\n", trim: true)

    [l0, l1, l2, "  #D#C#B#A#", "  #D#B#A#C#", l3, l4]
    |> Enum.join("\n")
    |> read2d()
  end

  ## config

  defp energy("A"), do: 1
  defp energy("B"), do: 10
  defp energy("C"), do: 100
  defp energy("D"), do: 1000

  defp home("A"), do: Enum.map(2..5, fn x -> {3, x} end)
  defp home("B"), do: Enum.map(2..5, fn x -> {5, x} end)
  defp home("C"), do: Enum.map(2..5, fn x -> {7, x} end)
  defp home("D"), do: Enum.map(2..5, fn x -> {9, x} end)

  defp not_stop() do
    [
      {3, 1},
      {5, 1},
      {7, 1},
      {9, 1}
    ]
  end

  defp progress(smap) do
    possible_moves(smap.map)
    |> Enum.map(fn move ->
      {map, cost} = move(smap.map, move, smap.current_cost)
      %{smap | current_cost: cost, map: map, id: map_id(map)}
    end)
  end

  defp print_smap(smap) do
    IO.puts("id: #{inspect(smap.id)}")
    IO.puts("current cost: #{smap.current_cost}")
    print(smap.map)
  end

  defp map_equal?(m1, m2) do
    map_id(m1) == map_id(m2)
  end

  defp map_id(map) do
    amps(map)
    |> Enum.sort()
  end

  defp possible_moves(map) do
    for {{x, y}, c} <- amps(map) do
      dsts =
        cond do
          settled?(map, {x, y}, c) ->
            []

          at_hallway?({x, y}) ->
            clean_home(map, c)

          at_room?({x, y}) ->
            hallway()
        end

      dsts
      |> Enum.reject(fn dst ->
        blocked?(map, {x, y}, dst) or dst in not_stop()
      end)
      |> Enum.map(fn dst -> {{x, y}, dst} end)
    end
    |> List.flatten()
  end

  defp clean_home(map, c) do
    cells = home(c) |> Enum.reverse()

    find_clean_buttom_cell(cells, map, c)
  end

  defp find_clean_buttom_cell([], _, _), do: raise("impossible")

  defp find_clean_buttom_cell([h | t], map, c) do
    case map[h] do
      "." ->
        [h]

      ^c ->
        find_clean_buttom_cell(t, map, c)

      _ ->
        []
    end
  end

  defp blocked?(map, {x0, y0}, {x1, y1}) do
    path1 =
      ((for y <- y0..y1 do
          {x0, y}
        end ++
          for x <- x0..x1 do
            {x, y1}
          end) -- [{x0, y0}])
      |> Enum.uniq()

    path2 =
      ((for y <- y0..y1 do
          {x1, y}
        end ++
          for x <- x0..x1 do
            {x, y0}
          end) -- [{x0, y0}])
      |> Enum.uniq()

    path_blocked?(map, path1) and path_blocked?(map, path2)
  end

  defp path_blocked?(map, path) do
    Enum.any?(path, fn p -> map[p] != "." end)
  end

  defp hallway() do
    for x <- 1..11 do
      {x, 1}
    end
  end

  defp at_hallway?({x, y}) do
    y == 1 and x in 1..11
  end

  defp at_room?({x, y}) do
    y in [2, 3, 4, 5] and x in [3, 5, 7, 9]
  end

  defp settled?(map, cord, c) do
    cord in home(c) and
      Enum.all?(Enum.filter(home(c), fn x -> x > cord end), fn x -> map[x] == c end)
  end

  defp amps(map) do
    Enum.filter(map, fn {_cord, c} ->
      c in ["A", "B", "C", "D"]
    end)
  end

  defp move(map, {from, to}, total_cost) do
    c = map[from]
    map = %{map | from => ".", to => c}
    total_cost = total_cost + cost(c, from, to)

    {map, total_cost}
  end

  defp cost(c, {x0, y0}, {x1, y1}) do
    (abs(y1 - y0) + abs(x1 - x0)) * energy(c)
  end

  defp done?(map) do
    Enum.all?(["A", "B", "C", "D"], fn c ->
      Enum.all?(home(c), fn cord ->
        map[cord] == c
      end)
    end)
  end

  defp print(grid) do
    for y <- 0..7 do
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

  # run

  def sol(map) do
    map =
      for {y, line} <- map, {x, c} <- line do
        {{x, y}, c}
      end
      |> Enum.into(%{})

    smap = %{
      map: map,
      current_cost: 0,
      id: map_id(map)
    }

    run(0, [smap], MapSet.new())
  end

  defp run(baduget, plans, archived) do
    IO.puts("baduget: #{baduget}")

    {new_plans, archived} =
      plans
      |> Enum.map_reduce(archived, fn smap, acc ->
        cond do
          MapSet.member?(acc, smap.id) ->
            # IO.puts("found archived plan")
            {[], acc}

          smap.current_cost <= baduget ->
            acc = MapSet.put(acc, smap.id)

            if done?(smap.map) do
              IO.puts("cost: #{smap.current_cost}")

              raise ""
            end

            new_plan = progress(smap)
            {new_plan, acc}

          true ->
            {smap, acc}
        end
      end)

    plans = List.flatten(new_plans)

    run(baduget + 1, plans, archived)
  end
end

# S.read(test_inputs)
# |> S.sol()

S.read(inputs)
|> S.sol()
