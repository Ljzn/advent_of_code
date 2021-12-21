inputs = File.read!("inputs/d17.dat")
test_inputs = File.read!("inputs/d17-test.dat")

defmodule S do
  def pre("target area: x=" <> str) do
    # 217..240, y=-126..-69
    str
    |> String.split(["..", ", y="])
    |> Enum.map(&String.to_integer/1)
    |> Enum.zip([:xl, :xh, :yl, :yh])
    |> Enum.map(fn {v, k} -> {k, v} end)
    |> Enum.into(%{})
    |> IO.inspect()
  end

  def sol(target = %{yl: yl, xh: xh}) do
    possible_ys =
      Enum.filter(yl..abs(yl), fn vy ->
        s = guess(%{vy: vy}, target, :x)
        s[:hit]
      end)
      |> Enum.to_list()
      |> IO.inspect(label: "ys")

    possible_xs =
      Enum.filter(0..abs(xh), fn vx ->
        s = guess(%{vx: vx}, target, :y)
        s[:hit]
      end)
      |> Enum.to_list()
      |> IO.inspect(label: "xs")

    for vx <- possible_xs, vy <- possible_ys do
      guess(%{vx: vx, vy: vy}, target)
    end
    |> Enum.filter(fn s -> s[:hit] end)
    |> IO.inspect()
    |> Enum.count()
  end

  defp guess(init, target, ignore \\ false) do
    loop(%{vy: 0, y: 0, vx: 0, x: 0} |> Map.merge(init) |> Map.put(:init, init), target, ignore)
  end

  defp loop(s, target, ignore) do
    IO.inspect(s)
    s = step(s)
    {rx, ry} = relation(target, s)

    cond do
      rx == :inside and ry == :inside ->
        s
        |> Map.put(:hit, true)

      (ignore == :x and ry == :inside) or (ignore == :y and rx == :inside) ->
        s
        |> Map.put(:hit, true)

      (ignore == :x and ry == :under) or (ignore == :y and rx == :right) ->
        s

      ignore == :y and s.vx == 0 ->
        s

      ignore == false and (ry == :under or rx == :right) ->
        s

      true ->
        s
        |> loop(target, ignore)
    end
  end

  defp relation(%{yl: yl, yh: yh, xl: xl, xh: xh}, %{y: y, x: x}) do
    ry =
      cond do
        y > yh -> :above
        y < yl -> :under
        true -> :inside
      end

    rx =
      cond do
        x > xh -> :right
        x < xl -> :left
        true -> :inside
      end

    {rx, ry}
  end

  defp step(%{vy: vy, y: y, vx: vx, x: x} = s) do
    %{s | vy: dvy(vy), y: y + vy, vx: dvx(vx), x: x + vx}
  end

  defp dvx(v) do
    if v > 0 do
      v - 1
    else
      if v < 0 do
        v + 1
      else
        0
      end
    end
  end

  defp dvy(v) do
    v - 1
  end
end

test_expect = 112

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
