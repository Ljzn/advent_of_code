inputs = File.read!("inputs/d22.dat")
test_inputs = File.read!("inputs/d22-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&structify/1)
  end

  # on x=-20..33,y=-21..23,z=-26..28
  defp parse_line(str) do
    str
    |> String.split([" ", "x=", "..", "y=", "z=", ","], trim: true)
    |> Enum.map(fn
      "on" -> :on
      "off" -> :off
      x -> String.to_integer(x)
    end)
  end

  defp structify([type, x1, x2, y1, y2, z1, z2]) do
    %{
      type: type,
      pps: [
        {:x, x1, x2 + 1},
        {:y, y1, y2 + 1},
        {:z, z1, z2 + 1}
      ]
    }
  end

  def sol(actions) do
    actions
    |> Enum.reduce([], fn a, state ->
      case a.type do
        :on ->
          union(state, a)

        :off ->
          diff(state, a)
      end
    end)
    |> light_ons()
  end

  defp light_ons(state) do
    Enum.map(state, fn x ->
      for {_, a, b} <- x.pps, reduce: 1 do
        acc ->
          acc * (b - a)
      end
    end)
    |> Enum.sum()
    |> IO.inspect(label: "light on")
  end

  def union([], x), do: [x]

  def union(a, b) when is_list(a) do
    r =
      Enum.reduce(a, [b], fn x, rest ->
        diff(rest, x)
      end)

    a ++ r
  end

  def diff(a, b) when is_list(a) do
    Enum.map(a, &do_diff(&1, b))
    |> List.flatten()
  end

  def do_diff(a, b) do
    case intersection(a.pps, b.pps) do
      nil ->
        a

      inter ->
        ways =
          Enum.zip(a.pps, inter)
          |> Enum.map(fn {{t, x1, y1}, {t, x2, y2}} ->
            {t, [{x1, x2}, {x2, y2}, {y2, y1}]}
          end)
          |> Enum.into(%{})

        children =
          for x <- ways.x, y <- ways.y, z <- ways.z do
            [
              tp(:x, x),
              tp(:y, y),
              tp(:z, z)
            ]
          end

        result = List.delete(children, inter)

        26 = length(result)

        result
        |> Enum.filter(&valid_pps/1)
        |> Enum.map(fn x -> %{pps: x} end)
    end
  end

  defp tp(a, {b, c}), do: {a, b, c}

  # a && b

  defp intersection(a, b) do
    pps =
      Enum.zip(a, b)
      |> Enum.map(fn {{t, x1, y1}, {t, x2, y2}} ->
        [{a1, b1}, {a2, b2}] = Enum.sort([{x1, y1}, {x2, y2}])
        {a, b} = intersect(a1, b1, a2, b2)
        {t, a, b}
      end)

    valid_pps(pps)
  end

  def valid_pps(pps) do
    if Enum.all?(pps, fn {_, a, b} -> a < b end) do
      pps
    else
      nil
    end
  end

  defp intersect(_a1, b1, a2, _b2) when b1 < a2, do: {0, 0}
  defp intersect(_a1, b1, a2, b2) when b1 >= a2 and b1 < b2, do: {a2, b1}
  defp intersect(_a1, b1, a2, b2) when b1 >= b2, do: {a2, b2}

  # [-50, 51)
  def limit(actions) do
    Enum.map(actions, fn x ->
      pps =
        x.pps
        |> Enum.map(fn {t, a, b} ->
          {t, do_limit(a, -50, 51), do_limit(b, -50, 51)}
        end)

      %{x | pps: pps}
    end)
  end

  defp do_limit(x, low, high) do
    cond do
      x > high -> high
      x < low -> low
      true -> x
    end
  end
end

# pre test

# """
# on x=10..12,y=10..12,z=10..12
# on x=11..13,y=11..13,z=11..13
# off x=9..11,y=9..11,z=9..11
# on x=10..10,y=10..10,z=10..10
# """
# |> S.pre()
# |> S.sol()
# |> IO.inspect()

# raise ""

# part1
test_expect = 590_784

^test_expect =
  test_inputs
  |> S.pre()
  |> S.limit()
  |> S.sol()

inputs
|> S.pre()
|> S.limit()
|> S.sol()
|> IO.inspect()

# part2

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
