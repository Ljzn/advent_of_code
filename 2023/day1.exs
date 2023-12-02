defmodule Trebuchet do
  def main(input) do
    main_build(%{first: &first_digit/1, last: &last_digit/1}).(input)
  end

  def main2(input) do
    main_build(%{first: &first_digit2/1, last: &last_digit2/1}).(input)
  end

  defp main_build(spec) do
    fn input ->
      input
      |> parse()
      |> Enum.map(fn line -> 10 * spec.first.(line) + spec.last.(line) end)
      |> Enum.sum()
    end
  end

  defp parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn line -> String.to_charlist(line) end)
  end

  defp first_digit([h | _t]) when h in ?0..?9 do
    h - ?0
  end

  defp first_digit([_ | t]), do: first_digit(t)

  defp last_digit(line), do: Enum.reverse(line) |> first_digit()

  @letters ~w(one two three four five six seven eight nine)c

  def first_digit2(line) do
    find(line, build_digit_map(@letters))
  end

  defp last_digit2(line) do
    find(Enum.reverse(line), build_digit_map(@letters |> Enum.map(fn w -> Enum.reverse(w) end)))
  end

  defp build_digit_map(letters) do
    value_map = Enum.with_index(letters, 1) |> Enum.into(%{})
    path_map = letters |> group_by_prefix()
    {value_map, path_map}
  end

  defp group_by_prefix(letters) do
    letters
    |> Enum.group_by(&hd/1, &tl/1)
    |> Enum.map(fn {k, v} -> {k, v |> Enum.reject(&(&1 == [])) |> group_by_prefix()} end)
    |> Enum.into(%{})
  end

  defp find(line, {value_map, path_map}) do
    do_find(line, value_map, path_map, [{path_map, []}])
  end

  defp do_find([h | _t], _, _, _) when h in ?0..?9, do: h - ?0

  defp do_find([h | t], value_map, path_map0, jobs) do
    result =
      Enum.flat_map(jobs, fn {path_map, stack} ->
        case path_map[h] do
          %{} = m when map_size(m) == 0 ->
            [value_map[stack ++ [h]]]

          nil ->
            [{path_map0, []}]

          remain_path_map ->
            [{path_map0, []}, {remain_path_map, stack ++ [h]}]
        end
      end)

    if r = Enum.find(result, fn x -> x in 1..9 end) do
      r
    else
      result
      |> Enum.reject(&is_nil/1)
      |> then(fn x ->
        do_find(t, value_map, path_map0, x)
      end)
    end
  end
end

142 =
  Trebuchet.main("""
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
  """)

281 =
  Trebuchet.main2("""
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  """)

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> &Trebuchet.main/1
    "2\n" -> &Trebuchet.main2/1
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
