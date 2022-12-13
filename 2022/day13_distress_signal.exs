defmodule DistressSignal do
  def parse(str, :pairs) do
    str
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse(&1, :pair))
  end

  def parse(str, :pair) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> Code.eval_string(x) |> elem(0) end)
  end

  def compare(a, b) when is_integer(a) and is_integer(b) do
    if a > b do
      :gt
    else
      if a < b do
        :lt
      else
        :eq
      end
    end
  end

  def compare([ha | ta], [hb | tb]) do
    case compare(ha, hb) do
      :eq ->
        compare(ta, tb)

      other ->
        other
    end
  end

  def compare([], [_ | _]), do: :lt
  def compare([_ | _], []), do: :gt
  def compare([], []), do: :eq

  def compare(a, b) when is_integer(a) and is_list(b) do
    compare([a], b)
  end

  def compare(a, b) when is_list(a) and is_integer(b) do
    compare(a, [b])
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> DistressSignal.parse(:pairs)
    |> Enum.with_index(1)
    |> Enum.filter(fn {[a, b], _i} ->
      DistressSignal.compare(a, b) == :lt
    end)
    |> Enum.map(fn {_, i} -> i end)
    |> IO.inspect()
    |> Enum.sum()
    |> inspect()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> DistressSignal.parse(:pairs)
    |> Enum.reduce([], fn [a, b], acc ->
      [a, b | acc]
    end)
    |> then(fn list ->
      [
        [[2]],
        [[6]] | list
      ]
    end)
    |> Enum.sort(fn a, b -> DistressSignal.compare(a, b) == :lt end)
    # |> IO.inspect()
    |> Enum.with_index(1)
    |> Enum.filter(fn {x, _} -> x == [[2]] or x == [[6]] end)
    |> Enum.map(fn {_, i} -> i end)
    |> then(fn [a, b] -> a * b end)
    |> inspect()
    |> IO.puts()
end
