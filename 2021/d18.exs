inputs = File.read!("inputs/d18.dat")
test_inputs = File.read!("inputs/d18-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> Code.eval_string(x) |> elem(0) end)
    |> Enum.map(&pathlize/1)
    |> Enum.map(&to_map/1)
  end

  defp pathlize(n) when is_integer(n) do
    [":#{n}"]
  end

  defp pathlize([a, b]) do
    [
      for p <- pathlize(a) do
        "0" <> p
      end,
      for p <- pathlize(b) do
        "1" <> p
      end
    ]
    |> List.flatten()
  end

  defp to_map(list) do
    for s <- list do
      [p, v] = String.split(s, ":")
      {p, String.to_integer(v)}
    end
    |> Enum.into(%{})
  end

  defp unpathlize([{"", v}]), do: v

  defp unpathlize(map) do
    map
    |> Enum.group_by(fn {k, _} -> String.length(k) end)
    |> Enum.sort(&>=/2)
    |> first_pack()
    |> unpathlize()
  end

  defp first_pack([{_l, ps} | t]) do
    ps =
      ps
      |> Enum.group_by(fn {k, _} -> parent(k) end)
      |> Enum.map(fn {k, v} -> {k, Enum.sort(v) |> Enum.map(&elem(&1, 1))} end)

    t = Enum.map(t, fn {_, v} -> v end) |> List.flatten()

    ps ++ t
  end

  def sol(numbers) do
    Enum.reduce(numbers, fn x, acc -> add(acc, x) end)
    |> Enum.into([])
    |> unpathlize()
    |> magnitude()
  end

  def sol2(numbers) do
    for x <- numbers, y <- numbers, y != x do
      add(x, y)
      |> Enum.into([])
      |> unpathlize()
      |> magnitude()
    end
    |> Enum.max()
  end

  defp magnitude([a, b]), do: 3 * magnitude(a) + 2 * magnitude(b)
  defp magnitude(n), do: n

  defp add(a, b) do
    a =
      for {k, v} <- a do
        {"0" <> k, v}
      end

    b =
      for {k, v} <- b do
        {"1" <> k, v}
      end

    m = (a ++ b) |> Enum.into(%{})

    {m, :init}
    |> re()
  end

  defp re({number, 0}), do: number

  defp re({number, _n}) do
    {number, 0}
    |> explode()
    |> split()
    |> re()
  end

  defp explode({number, 0}) do
    do_explode(number)
  end

  defp do_explode(number) do
    ps = Map.keys(number) |> Enum.sort()

    %{left: left, e1: e1, e2: e2, right: right} =
      find_explodes(ps, %{left: nil, right: nil, e1: nil, e2: nil})

    if e1 do
      news =
        [
          {left, (number[left] || 0) + number[e1]},
          {right, (number[right] || 0) + number[e2]},
          {parent(e1), 0}
        ]
        |> Enum.reject(fn {k, _} -> is_nil(k) end)
        |> Enum.into(%{})

      {number
       |> Map.drop([e1, e2])
       |> Map.merge(news), 1}
    else
      {number, 0}
    end
  end

  defp parent(p) do
    p |> String.slice(0..-2//1)
  end

  defp head([]), do: nil
  defp head(l), do: hd(l)

  defp find_explodes([h1, h2 | t], s) do
    if String.length(h1) > 4 do
      s |> Map.put(:e1, h1) |> Map.put(:e2, h2) |> Map.put(:right, head(t))
    else
      find_explodes([h2 | t], Map.put(s, :left, h1))
    end
  end

  defp find_explodes(_, s), do: s

  defp split({number, 1}), do: {number, 1}

  defp split({number, 0}) do
    ps = Enum.sort(Map.keys(number))
    p = Enum.find(ps, fn p -> number[p] >= 10 end)

    if p do
      news =
        [
          {p <> "0", trunc(number[p] / 2)},
          {p <> "1", round(number[p] / 2)}
        ]
        |> Enum.into(%{})

      {number |> Map.delete(p) |> Map.merge(news), 1}
    else
      {number, 0}
    end
  end
end

# part1
test_expect = 4140

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()

# part2
test_expect = 3993

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol2()

inputs
|> S.pre()
|> S.sol2()
|> IO.inspect()
