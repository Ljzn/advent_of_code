defmodule TuningTrouble do
  def marker?(a, a, _, _), do: false
  def marker?(a, _, a, _), do: false
  def marker?(a, _, _, a), do: false
  def marker?(_, a, a, _), do: false
  def marker?(_, a, _, a), do: false
  def marker?(_, _, a, a), do: false
  def marker?(_, _, _, _), do: true

  def process(list, type) do
    len =
      case type do
        :packet -> 4
        :message -> 14
      end

    {start, list} = Enum.split(list, len)
    do_process(start, list, len, type)
  end

  defp do_process(four, list, i, :packet) do
    if apply(&marker?/4, four) do
      i
    else
      do_process(tl(four) ++ [hd(list)], tl(list), i + 1, :packet)
    end
  end

  defp do_process(start, list, i, :message) do
    find_distinct(Enum.frequencies(start), start, list, i)
  end

  defp find_distinct(map, [h | t], [append | rest], i) do
    if Enum.all?(Map.values(map), fn x -> x <= 1 end) do
      i
    else
      map
      |> Map.update!(h, fn v -> v - 1 end)
      |> Map.update(append, 1, fn v -> v + 1 end)
      |> find_distinct(t ++ [append], rest, i + 1)
    end
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> String.to_charlist()
    |> TuningTrouble.process(:packet)
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> String.to_charlist()
    |> TuningTrouble.process(:message)
    |> IO.puts()
end
