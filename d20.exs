inputs = File.read!("inputs/d20.dat")
test_inputs = File.read!("inputs/d20-test.dat")

defmodule S do
  def pre(str) do
    [code, grid] =
      str
      |> String.split("\n\n", trim: true)

    {parse_code(code), parse_grid(grid)}
  end

  defp parse_code(code) do
    code = String.replace(code, "\n", "")

    for c <- String.to_charlist(code) do
      case c do
        ?. -> 0
        ?# -> 1
      end
    end
    |> Enum.with_index()
    |> Enum.map(fn {v, i} -> {i, v} end)
    |> Enum.into(%{})
  end

  defp parse_grid(grid) do
    grid =
      grid
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> String.to_charlist(line) end)

    for {line, y} <- grid |> Enum.with_index() do
      for {v, x} <- line |> Enum.with_index() do
        v =
          case v do
            ?. -> 0
            ?# -> 1
          end

        {{x, y}, v}
      end
    end
    |> List.flatten()
    |> Enum.into(%{})
    |> wrap()
    |> Map.put(nil, 0)
  end

  defp wrap(grid) do
    {{x, y}, _} = Enum.max(grid)

    (for a <- -1..(x + 1) do
       [
         {{a, -1}, 0},
         {{a, y + 1}, 0}
       ]
     end ++
       for b <- 0..y do
         [
           {{-1, b}, 0},
           {{x + 1, b}, 0}
         ]
       end)
    |> List.flatten()
    |> Enum.into(%{})
    |> Map.merge(grid)
  end

  def sol({code_map, grid}) do
    print(grid)

    run(grid, code_map, 2)
  end

  defp run(grid, code_map, n) do
    Enum.reduce(1..n, grid, fn _, acc -> loop(acc, code_map) end)
    |> Enum.count(fn {_, v} -> v == 1 end)
  end

  def sol2({code_map, grid}) do
    print(grid)

    run(grid, code_map, 50)
  end

  def loop(grid, code_map) do
    new_edge_value = new_value_of_point(grid, code_map, nil)

    grid
    |> Enum.reduce(%{}, fn unit, acc ->
      new_units = analyze_unit(grid, code_map, unit, new_edge_value)
      # |> IO.inspect(label: "old: #{inspect(unit)}, new")

      Map.merge(acc, new_units, fn _k, v, v ->
        v
      end)
    end)
    |> Map.put(nil, new_edge_value)
    |> tap(&print/1)
  end

  defp analyze_unit(grid, code_map, {point, _v}, new_edge_value) do
    if is_edge(grid, point) and is_mix(grid, point) do
      new_edge_units(grid, point, new_edge_value)
    else
      %{}
    end
    |> Map.put(point, new_value_of_point(grid, code_map, point))
  end

  defp is_edge(grid, point) do
    adjusts(point)
    |> Enum.any?(fn x -> grid[x] |> is_nil() end)
  end

  defp adjusts(nil), do: List.duplicate(nil, 8)

  defp adjusts({x, y}) do
    for a <- -1..1, b <- -1..1, uniq: true do
      {x + a, y + b}
    end
  end

  defp is_mix(grid, point) do
    l =
      adjusts(point)
      |> Enum.map(fn x -> grid[x] || grid[nil] end)
      |> Enum.uniq()
      |> length()

    l > 1
  end

  defp new_edge_units(grid, point, new_edge_value) do
    adjusts(point)
    |> Enum.map(fn x ->
      if grid[x] do
        nil
      else
        {x, new_edge_value}
      end
    end)
    |> Enum.filter(& &1)
    |> Enum.into(%{})
  end

  defp new_value_of_point(grid, code_map, point) do
    code_map[
      adjusts(point)
      |> Enum.sort_by(fn
        {x, y} -> {y, x}
        nil -> nil
      end)
      |> Enum.map(fn p -> grid[p] || grid[nil] end)
      |> Integer.undigits(2)
    ]
  end

  defp print(grid) do
    for y <- -200..200 do
      for x <- -200..200 do
        case grid[{x, y}] || grid[nil] do
          0 -> "."
          1 -> "#"
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    |> IO.puts()

    IO.puts("\n")
  end
end

# part1
test_expect = 35

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()

# part2
test_expect = 3351

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol2()

inputs
|> S.pre()
|> S.sol2()
|> IO.inspect()
