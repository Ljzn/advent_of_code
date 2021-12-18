inputs = File.read!("inputs/d15.dat")
test_inputs = File.read!("inputs/d15-test.dat")

# FIXME it's not a right solution, just correct with good luck :P
defmodule S do
  def pre(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
      |> Enum.map(fn c -> c - ?0 end)
    end)
  end

  def sol(grid) do
    map =
      for {line, y} <- grid |> Enum.with_index() do
        for {v, x} <- line |> Enum.with_index() do
          {{x, y}, v}
        end
      end
      |> List.flatten()
      |> Enum.into(%{})

    run(map, 0)
  end

  defp run(map, layer) do
    nodes =
      for x <- 0..layer do
        {x, layer - x}
      end
      |> Enum.filter(fn node -> map[node] end)

    map =
      Enum.reduce(nodes, map, fn {x, y}, acc ->
        up = {x, y - 1}
        left = {x - 1, y}

        acc
        |> update_risk({x, y}, up)
        |> update_risk({x, y}, left)
        |> min_risk({x, y})
      end)

    case nodes do
      [{x, y}] when x > 0 ->
        map[{x, y}] - map[{0, 0}]

      _ ->
        run(map, layer + 1)
    end
  end

  defp update_risk(map, node, ngb) do
    if ngb_risk = map[ngb] do
      Map.update!(map, node, fn
        risk when is_integer(risk) ->
          {risk, [risk + ngb_risk]}

        {risk, risks} ->
          {risk, [risk + ngb_risk | risks]}
      end)
    else
      map
    end
  end

  defp min_risk(map, node) do
    Map.update!(map, node, fn
      risk when is_integer(risk) ->
        risk

      {_, risks} ->
        Enum.min(risks)
    end)
  end
end

test_expect = 40

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
