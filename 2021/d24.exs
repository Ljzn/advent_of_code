inputs = File.read!("inputs/d24.dat")

defmodule S do
  @moduledoc """
  Thanks ephemient's excellent answer! Rewrote from https://github.com/ephemient/aoc2021/blob/main/rs/src/day24.rs .
  """

  @doc """
  Parse instructions.
  """
  def parse(str) do
    str
    |> String.split("\n")
    |> Enum.map(fn line ->
      case String.split(line, " ") do
        [h | t] ->
          {parse_op(h), parse_args(t)}
      end
    end)
  end

  defp parse_op(op) when op in ~w(inp add mul div mod eql), do: String.to_atom(op)

  defp parse_args(list) do
    list
    |> Enum.map(fn x ->
      if x in ~w(w x y z) do
        String.to_atom(x)
      else
        String.to_integer(x)
      end
    end)
  end

  def new_alu, do: %{w: 0, x: 0, y: 0, z: 0}

  @nothing :nothing

  def check_range(ins, alu) do
    alu =
      for {r, v} <- alu, into: %{} do
        {r, {v, v}}
      end

    alu =
      ins
      |> Enum.reduce_while(alu, fn inst, alu ->
        case inst do
          {:inp, [lhs]} ->
            {:cont, %{alu | lhs => {1, 9}}}

          {op, [lhs, rhs]} ->
            {a, b} = alu[lhs]
            {c, d} = alu[rhs] || {rhs, rhs}

            lhs_range =
              case op do
                :add ->
                  {a + c, b + d}

                :mul ->
                  Enum.min_max([a * c, a * d, b * c, b * d])

                :div ->
                  cond do
                    c > 0 ->
                      {div(a, d), div(b, c)}

                    d < 0 ->
                      {div(b, d), div(a, c)}

                    true ->
                      @nothing
                  end

                :mod ->
                  if c > 0 and c == d do
                    if b - a + 1 < c and rem(a, c) <= rem(b, c) do
                      {rem(a, c), rem(b, c)}
                    else
                      {0, c - 1}
                    end
                  else
                    @nothing
                  end

                :eql ->
                  cond do
                    a == b and c == d and a == c ->
                      {1, 1}

                    a <= d and b >= c ->
                      {0, 1}

                    true ->
                      {0, 0}
                  end
              end

            case lhs_range do
              {a, b} ->
                {:cont, %{alu | lhs => {a, b}}}

              @nothing ->
                {:halt, @nothing}
            end
        end
      end)

    case alu do
      @nothing ->
        @nothing

      %{z: {a, b}} ->
        a <= 0 and b >= 0
    end
  end

  def solve([], _, prefix, alu) do
    if alu.z == 0 do
      prefix
    else
      nil
    end
  end

  def solve([inst | rest], nums, prefix, alu) do
    IO.inspect(prefix, label: "prefix")

    case inst do
      {:inp, [lhs]} ->
        nums
        |> Enum.find_value(fn num ->
          alu = %{alu | lhs => num}

          if check_range(rest, alu) != false do
            solve(rest, nums, 10 * prefix + num, alu)
          else
            nil
          end
        end)

      {op, [lhs, rhs]} ->
        a = alu[lhs]
        b = alu[rhs] || rhs

        result =
          case op do
            :add -> a + b
            :mul -> a * b
            :div -> div(a, b)
            :mod -> rem(a, b)
            :eql -> if(a == b, do: 1, else: 0)
          end

        solve(rest, nums, prefix, %{alu | lhs => result})
    end
  end
end

# test

insts =
  inputs
  |> S.parse()

# part 1
S.solve(insts, Enum.to_list(9..1), 0, S.new_alu())
|> IO.inspect()

# part 2
S.solve(insts, Enum.to_list(1..9), 0, S.new_alu())
|> IO.inspect()
