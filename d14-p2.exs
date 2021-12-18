inputs = File.read!("inputs/d14.dat")
test_inputs = File.read!("inputs/d14-test.dat")

defmodule S do
  def pre(str) do
    [a, rules] =
      str
      |> String.split("\n\n", trim: true)

    a =
      a
      |> String.split("", trim: true)

    rules =
      rules
      |> String.split("\n", trim: true)
      |> Enum.map(fn
        <<x1::binary-size(1), x2::binary-size(1)>> <> " -> " <> y ->
          {{x1, x2}, y}
      end)
      |> Enum.into(%{})

    {a, rules}
  end

  defp to_map(m) when is_map(m), do: m
  defp to_map({k, v}), do: %{k => v}

  defp add_merge(m1, m2), do: Map.merge(to_map(m1), to_map(m2), fn _k, v1, v2 -> v1 + v2 end)

  def sol({a, rules}) do
    m0 = to_line_map(a, %{})

    step = fn m ->
      m
      |> Enum.map(fn
        {{x1, x2}, n} ->
          one_step(rules, x1, x2)
          |> Enum.map(fn {k, v} -> {k, v * n} end)

        {x, n} ->
          {x, n}
      end)
      |> List.flatten()
      |> Enum.reduce(&add_merge/2)
    end

    run(m0, step, 40)
    |> Enum.map(fn
      {{x1, x2}, n} -> [{x1, n}, {x2, n}]
      {x, n} -> {x, n}
    end)
    |> List.flatten()
    |> Enum.reduce(&add_merge/2)
    |> Map.values()
    |> then(fn x -> Enum.max(x) - Enum.min(x) end)
  end

  defp run(m, _fun, 0), do: m
  defp run(m, fun, n), do: run(fun.(m), fun, n - 1)

  defp to_line_map([x1, x2], m) do
    add_merge(m, %{{x1, x2} => 1})
  end

  defp to_line_map([x1, x2 | t], m) do
    to_line_map([x2 | t], add_merge(m, %{{x1, x2} => 1, x2 => -1}))
  end

  defp one_step(rules, x1, x2) do
    y = rules[{x1, x2}]
    %{{x1, y} => 1, {y, x2} => 1, y => -1}
  end
end

test_expect = 2_188_189_693_529

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
