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

  def sol(target = %{yl: yl}) do
    vy =
      Enum.filter(0..abs(yl), fn vy ->
        guess(vy, target)[:last_inside_y] == yl
      end)
      |> Enum.to_list()
      |> Enum.max()

    guess(vy, target).syh
  end

  defp guess(vy, target) do
    loop(%{vy: vy, y: 0, vx: 0, x: 0}, target) |> IO.inspect()
  end

  defp loop(s, target) do
    s = step(s)

    case relation(target, s) do
      :above ->
        loop(s, target)

      :under ->
        s

      :inside ->
        s
        |> Map.put(:last_inside_y, s.y)
        |> loop(target)
    end
  end

  defp relation(%{yl: yl, yh: yh}, %{y: y}) do
    cond do
      y > yh -> :above
      y < yl -> :under
      true -> :inside
    end
  end

  defp step(%{vy: vy, y: y, vx: vx, x: x} = s) do
    %{s | vy: dvy(vy), y: y + vy, vx: dvx(vx), x: x + vx}
    |> then(fn s ->
      if vy == 0 do
        Map.put(s, :syh, y)
      else
        s
      end
    end)
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

test_expect = 45

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
