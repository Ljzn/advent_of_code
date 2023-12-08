defmodule Wasteland do
  def main(input) do
    %{insts: insts, nets: nets} = parse(input)

    steps_to(insts, nets, "AAA", &(&1 == "ZZZ"))
  end

  defp steps_to(insts, nets, start, ending) do
    Stream.cycle(insts)
    |> Enum.reduce_while({start, 0}, fn
      inst, {from, steps} ->
        to = nets[from][inst]
        steps = steps + 1

        if ending.(to) do
          {:halt, steps}
        else
          {:cont, {to, steps}}
        end
    end)
  end

  # life is too short to solve problems like this
  def main2(input) do
    %{insts: insts, nets: nets} = parse(input)

    starts = start_points(nets)

    Enum.map(starts, &steps_to(insts, nets, &1, fn x -> String.ends_with?(x, "Z") end))
    |> lcm()
  end

  defp parse(input) do
    [insts, nets] = String.split(input, "\n\n", trim: true)

    %{
      insts: String.to_charlist(insts),
      nets:
        String.split(nets, "\n", trim: true)
        |> Enum.map(fn line ->
          [n, l, r] = String.split(line, [" = (", ", ", ")"], trim: true)
          {n, %{?L => l, ?R => r}}
        end)
        |> Enum.into(%{})
    }
  end

  defp start_points(nets) do
    nets |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "A"))
  end

  defp lcm(list) do
    Enum.reduce(list, &lcm/2)
  end

  defp lcm(a, b) do
    g = gcd(a, b)
    g * div(a, g) * div(b, g)
  end

  defp gcd(a, b) when a < b, do: gcd(b, a)
  defp gcd(a, b) when rem(a, b) == 0, do: b
  defp gcd(a, b), do: gcd(b, rem(a, b))
end

input = """
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
"""

input2 = """
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"""

r1 = 6
r2 = 6
mod = Wasteland

########## COPY & PASTE FOLLOWING CODE ##########

f1 = &mod.main/1
f2 = &mod.main2/1

^r1 = f1.(input)
^r2 = f2.(input2)

f =
  case IO.gets("Input the part number (1 or 2):\n") do
    "1\n" -> f1
    "2\n" -> f2
  end

IO.stream(:line)
|> Stream.take_while(&(&1 != "done\n"))
|> Enum.join()
|> f.()
|> IO.puts()
