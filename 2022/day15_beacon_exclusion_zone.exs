defmodule BeaconExclusionZone do
  def parse(str, :record) do
    str
    |> String.split(["Sensor at x=", ", y=", ": closest beacon is at x=", ", y="], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse(str, :records) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse(&1, :record))
  end

  def distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def get_exclusive_x_range_at_y(sx, sy, y, d) do
    dx = d - distance({sx, sy}, {sx, y})

    if dx >= 0 do
      {sx - dx, sx + dx}
    else
      nil
    end
  end

  def merge_ranges(list) do
    list
    |> Enum.filter(& &1)
    |> Enum.sort()
    |> do_merge([])
  end

  defp do_merge([{l1, r1}, {l2, r2} | t], result) do
    cond do
      r1 < l2 - 1 ->
        do_merge([{l2, r2} | t], [{l1, r1} | result])

      r1 >= l2 - 1 ->
        do_merge([{l1, max(r1, r2)} | t], result)
    end
  end

  defp do_merge([{l, r}], result) do
    [{l, r} | result]
  end

  def total_length(list) do
    list
    |> Enum.map(fn {l, r} -> r - l + 1 end)
    |> Enum.sum()
  end

  def tf(x, y) do
    x * 4_000_000 + y
  end

  def find_hole(ranges, min, max) do
    ranges
    |> Enum.map(fn {l, r} -> [l, r] end)
    |> List.flatten()
    |> Enum.sort()
    |> Enum.find(fn x -> x > min and x < max end)
    |> then(fn x ->
      if x do
        x + 1
      end
    end)
  end
end

# y = 10
y = 2_000_000

# max = 20
max = 4_000_000

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> BeaconExclusionZone.parse(:records)
    |> Enum.reduce({[], MapSet.new()}, fn [sx, sy, bx, by], {es, be} ->
      d = BeaconExclusionZone.distance({sx, sy}, {bx, by})

      es = [BeaconExclusionZone.get_exclusive_x_range_at_y(sx, sy, y, d) | es]

      {es, MapSet.put(be, {bx, by})}
    end)
    |> then(fn {es, be} ->
      es = BeaconExclusionZone.merge_ranges(es)
      BeaconExclusionZone.total_length(es) - Enum.count(be, fn {_, y1} -> y1 == y end)
    end)
    |> inspect()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> BeaconExclusionZone.parse(:records)
    |> then(fn records ->
      0..max
      |> Enum.map(fn y ->
        x =
          records
          |> Enum.reduce([], fn [sx, sy, bx, by], es ->
            d = BeaconExclusionZone.distance({sx, sy}, {bx, by})

            [BeaconExclusionZone.get_exclusive_x_range_at_y(sx, sy, y, d) | es]
          end)
          |> then(fn es ->
            BeaconExclusionZone.merge_ranges(es)
          end)
          |> BeaconExclusionZone.find_hole(0, max)

        if x do
          BeaconExclusionZone.tf(x, y)
        end
      end)
    end)
    |> Enum.find(& &1)
    |> inspect()
    |> IO.puts()
end
