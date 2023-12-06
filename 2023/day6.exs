defmodule WaitForIt do
  def main(input) do
    parse(input)
    |> Enum.map(fn {t, d} -> solve(t, d) end)
    |> Enum.reduce(&(&1 * &2))
  end

  def main2(input) do
    [t, d] = parse2(input)
    solve(t, d)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, ["Time:", "Distance:", " "], trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
  end

  defp parse2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, ["Time:", "Distance:", " "], trim: true)
      |> Enum.join()
      |> String.to_integer()
    end)
  end

  # (t - x)*x > d
  # -x*x + tx - d > 0
  def solve(t, d) do
    a = -1
    b = t
    c = -d

    delt = b * b - 4 * a * c

    if delt < 0 do
      0
    else
      x1 = (-b - :math.sqrt(delt)) / (2 * a)
      x2 = (-b + :math.sqrt(delt)) / (2 * a)

      r = trunc(x1) - ceil(x2) + 1
      r - if(x1 == trunc(x1), do: 1, else: 0) - if x2 == trunc(x2), do: 1, else: 0
    end
  end
end

288 =
  """
  Time:      7  15   30
  Distance:  9  40  200
  """
  |> WaitForIt.main()

71503 =
  """
  Time:      7  15   30
  Distance:  9  40  200
  """
  |> WaitForIt.main2()

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> &WaitForIt.main/1
    "2\n" -> &WaitForIt.main2/1
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
