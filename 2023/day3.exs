defmodule GearRatios do
  @init %{
    x: 0,
    y: 0,
    v: 0,
    s: {0, 0},
    e: {0, 0},
    nums: %{},
    symbols: %{}
  }

  def main(input) do
    ctx = parse(String.to_charlist(input), @init)

    ctx.nums
    |> Enum.filter(&is_part_number?(&1, ctx.symbols))
    |> Enum.map(fn {_, n} -> n end)
    |> Enum.sum()
  end

  def main2(input) do
    ctx = parse(String.to_charlist(input), @init)

    {id_num_map, cord_id_map} = build_maps(ctx.nums)

    ctx.symbols
    |> Enum.filter(fn {_, s} -> s == ?* end)
    |> Enum.map(&part_numbers(elem(&1, 0), cord_id_map, id_num_map))
    |> Enum.filter(&(length(&1) == 2))
    |> Enum.map(fn [a, b] -> a * b end)
    |> Enum.sum()
  end

  defp parse([h | t], ctx) when h in ?0..?9 do
    ctx = %{
      ctx
      | x: ctx.x + 1,
        v: ctx.v * 10 + h - ?0,
        s: if(ctx.v == 0, do: {ctx.x, ctx.y}, else: ctx.s),
        e: {ctx.x, ctx.y}
    }

    parse(t, ctx)
  end

  defp parse([h | t], ctx) do
    {x, y} =
      if h == ?\n do
        {0, ctx.y + 1}
      else
        {ctx.x + 1, ctx.y}
      end

    {nums, v} =
      if ctx.v != 0 do
        {Map.put_new(ctx.nums, %{s: ctx.s, e: ctx.e}, ctx.v), 0}
      else
        {ctx.nums, 0}
      end

    symbols =
      if h != ?. and h != ?\n do
        Map.put_new(ctx.symbols, {ctx.x, ctx.y}, h)
      else
        ctx.symbols
      end

    parse(t, %{ctx | x: x, y: y, v: v, s: {0, 0}, e: {0, 0}, nums: nums, symbols: symbols})
  end

  defp parse([], ctx), do: ctx

  defp is_part_number?({%{s: {sx, y}, e: {ex, y}}, _}, symbols) do
    for x <- (sx - 1)..(ex + 1), y <- (y - 1)..(y + 1) do
      {x, y}
    end
    |> Enum.any?(fn {x, y} -> symbols[{x, y}] end)
  end

  defp build_maps(nums) do
    {m1, m2, _} =
      nums
      |> Enum.reduce({%{}, %{}, 0}, fn {%{s: {sx, y}, e: {ex, y}}, v},
                                       {id_num_map, cord_id_map, id} ->
        cord_id_map =
          Enum.reduce(sx..ex, cord_id_map, fn x, acc ->
            Map.put_new(acc, {x, y}, id)
          end)

        {Map.put(id_num_map, id, v), cord_id_map, id + 1}
      end)

    {m1, m2}
  end

  defp part_numbers({x, y}, cord_id_map, id_num_map) do
    for x <- (x - 1)..(x + 1), y <- (y - 1)..(y + 1) do
      cord_id_map[{x, y}]
    end
    |> Enum.filter(& &1)
    |> Enum.uniq()
    |> Enum.map(&id_num_map[&1])
  end
end

4361 =
  """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  """
  |> GearRatios.main()

467_835 =
  """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  """
  |> GearRatios.main2()

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> &GearRatios.main/1
    "2\n" -> &GearRatios.main2/1
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
