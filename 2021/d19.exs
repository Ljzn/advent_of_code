inputs = File.read!("inputs/d19.dat")
test_inputs = File.read!("inputs/d19-test.dat")

defmodule S do
  def pre(str) do
    report =
      str
      |> String.split("\n\n", trim: true)
      |> Enum.map(&parse_scanner/1)
      |> Enum.into(%{})

    # sid: line id of 2 points
    n_sids =
      for {number, data} <- report do
        sids =
          for {i1, _} <- data, {i2, _} <- data, i1 < i2 do
            {{i1, i2}, sid(data, i1, i2)}
          end

        {number, sids}
      end

    transform_maps =
      for {number1, sids1} <- n_sids, {number2, sids2} <- n_sids, number1 < number2 do
        same_sids = same_sids(sids1, sids2)

        # connect lines of 12 points
        if (len = length(same_sids)) >= 12 * 11 / 2 do
          IO.inspect(len, label: "same sids")
          {number1, number2, get_overlap_points(same_sids)}
        else
          nil
        end
      end
      |> Enum.filter(& &1)
      |> Enum.map(&get_transform_axis(&1, report))
      |> IO.inspect(label: "Transform Maps")

    trans_paths =
      transform_maps
      |> Enum.map(fn {a, b, _} -> {a, b} end)
      |> find_to_zero_paths(length(n_sids))
      |> IO.inspect(label: "trans_paths")

    {report |> Enum.map(fn {number, data} -> {number, Map.values(data)} end), transform_maps,
     trans_paths}
  end

  defp parse_scanner(str) do
    [title | data] = String.split(str, "\n")

    number =
      String.trim_leading(title, "--- scanner ")
      |> String.trim_trailing(" ---")
      |> String.to_integer()

    data =
      Enum.map(data, fn x ->
        [x, y, z] = String.split(x, ",") |> Enum.map(&String.to_integer/1)
        {x, y, z}
      end)
      |> Enum.with_index()
      |> Enum.map(fn {d, i} -> {i, d} end)
      |> Enum.into(%{})

    {number, data}
  end

  defp sid(data, a, b) do
    {x1, y1, z1} = data[a]
    {x2, y2, z2} = data[b]

    :math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2) + :math.pow(z1 - z2, 2)
  end

  defp to_points({report, transform_maps, trans_paths}) do
    report
    |> Enum.map(fn
      {0, data} ->
        data

      {number, data} ->
        trans_paths[number]
        |> Enum.reduce({number, []}, fn dst, {last, ways} ->
          {dst, [{last, dst} | ways]}
        end)
        |> elem(1)
        |> Enum.reverse()
        |> Enum.map(fn {a, b} ->
          case Enum.find(transform_maps, &match?({^a, ^b, _}, &1)) do
            {_, _, axis_maps} ->
              axis_maps

            nil ->
              tm1 = Enum.find(transform_maps, &match?({^b, ^a, _}, &1))
              tm2 = tm1 |> reverse_transform_axis()

              # assertions
              ^tm1 = tm2 |> reverse_transform_axis()
              ^data = data |> transform(elem(tm1, 2)) |> transform(elem(tm2, 2))

              elem(tm2, 2)
          end
        end)
        |> Enum.reduce(data, fn am, acc -> transform(acc, am) end)
    end)
    |> List.flatten()
    |> Enum.uniq()
  end

  def sol(info) do
    points = to_points(info)

    points
    |> Enum.sort()
    |> Enum.count()
  end

  def sol2({report, transform_maps, trans_paths}) do
    report =
      Enum.map(report, fn {number, ps} ->
        {number, [{0, 0, 0}]}
      end)

    points = to_points({report, transform_maps, trans_paths})

    for a <- points, b <- points, a < b do
      {x1, y1, z1} = a
      {x2, y2, z2} = b
      {abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2), a, b}
    end
    |> Enum.max()
    |> elem(0)
  end

  defp find_to_zero_paths(list, n) do
    all_paths =
      for {a, b} <- list, reduce: %{} do
        acc -> Map.merge(acc, %{a => [b], b => [a]}, fn _k, v1, v2 -> Enum.uniq(v1 ++ v2) end)
      end
      |> IO.inspect(label: "all paths")

    for x <- 1..(n - 1) do
      {x, do_find_to_zero_paths(all_paths, x, [])}
    end
    |> Enum.into(%{})
    |> IO.inspect(label: "to zero paths")
  end

  defp do_find_to_zero_paths(all_paths, x, p) do
    # FIXME
    if length(p) > 20 do
      List.duplicate(:no, 999)
    else
      if 0 in all_paths[x] do
        p ++ [0]
      else
        case all_paths[x]
             |> IO.inspect(label: "all path of #{x}, p is #{inspect(p)}")
             |> Enum.reject(fn c -> c in p end) do
          [] ->
            List.duplicate(:no, 999)

          list ->
            list
            |> Enum.map(fn c -> do_find_to_zero_paths(all_paths, c, p ++ [c]) end)
            |> Enum.min_by(&length/1)
        end
      end
    end
  end

  defp same_sids(l1, l2) do
    for {i1, v1} <- l1, {i2, v2} <- l2, v1 == v2 do
      {i1, i2}
    end
    |> reject_noise()
  end

  defp reject_noise(list) do
    case(
      list
      |> Enum.map(fn {{a, b}, _} -> [a, b] end)
      |> List.flatten()
      |> Enum.frequencies()
      |> Enum.find(fn {_, f} -> f < 11 end)
    ) do
      {a, _} ->
        list
        |> Enum.reject(fn {i1, _i2} -> a in Tuple.to_list(i1) end)

      _ ->
        list
    end
  end

  defp get_overlap_points(list) do
    for {{a, b}, {c, d}} <- list, reduce: %{} do
      acc ->
        new = %{a => [c, d], b => [c, d]}
        Map.merge(acc, new, fn _k, v1, v2 -> v1 -- v1 -- v2 end)
    end
    |> Enum.map(fn {k, [v]} -> {k, v} end)
    |> Enum.into(%{})
  end

  defp get_transform_axis({s1, s2, point_map}, report) do
    {ps1, ps2} =
      for {p1, p2} <- point_map, reduce: {[], []} do
        {l1, l2} ->
          {[report[s1][p1] | l1], [report[s2][p2] | l2]}
      end

    axis_maps =
      for {a1, v1} <- aids(ps1), {a2, v2} <- aids(ps2), v1 == v2 do
        {direction, offset} = diff(ps1, a1, ps2, a2)

        # {a2, fn as -> elem(as, a1) * direction + offset end}
        {a2, {a1, direction, offset}}
      end
      |> Enum.sort()
      |> Enum.map(fn {_, v} -> v end)

    # verify axis map
    ^ps2 = transform(ps1, axis_maps)

    {s1, s2, axis_maps}
  end

  defp reverse_transform_axis({s1, s2, axis_maps}) do
    {s2, s1,
     axis_maps
     |> Enum.with_index()
     |> Enum.map(fn
       {{a, dir, off}, i} ->
         {a, {i, dir, off, :reverse}}

       {{a, dir, off, :reverse}, i} ->
         {a, {i, dir, off}}
     end)
     |> Enum.sort()
     |> Enum.map(fn {_, v} -> v end)}
  end

  defp transform(ps1, axis_maps) when is_list(ps1) do
    for p <- ps1 do
      transform(p, axis_maps)
    end
  end

  # transform point {x, y, z} to another coordination by axis maps
  defp transform(p, axis_maps) do
    Enum.reduce(axis_maps, {}, fn
      {a, direction, offset}, acc ->
        acc |> Tuple.append(elem(p, a) * direction + offset)

      {a, direction, offset, :reverse}, acc ->
        acc |> Tuple.append((elem(p, a) - offset) * direction)
    end)
  end

  defp diff(ps1, a1, ps2, a2) do
    [h11, h12 | _] = Enum.map(ps1, fn e -> elem(e, a1) end)
    [h21, h22 | _] = Enum.map(ps2, fn e -> elem(e, a2) end)

    cond do
      h21 - h11 == h22 - h12 ->
        {1, h21 - h11}

      h21 - -h11 == h22 - -h12 ->
        {-1, h21 - -h11}
    end
  end

  def sign(n) when n > 0, do: 1
  def sign(n) when n < 0, do: -1

  defp aids([h | t] = points) do
    {ax, ay, az} =
      points
      |> Enum.zip(t ++ [h])
      |> Enum.reduce({0, 0, 0}, fn {{x1, y1, z1}, {x2, y2, z2}}, {ax, ay, az} ->
        {
          ax + :math.pow(x1 - x2, 2),
          ay + :math.pow(y1 - y2, 2),
          az + :math.pow(z1 - z2, 2)
        }
      end)

    %{
      0 => ax,
      1 => ay,
      2 => az
    }
  end
end

# part1
test_expect = 79

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

IO.puts("test passed")

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()

# part 2

test_expect = 3621

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol2()

IO.puts("test2 passed")

inputs
|> S.pre()
|> S.sol2()
|> IO.inspect()
