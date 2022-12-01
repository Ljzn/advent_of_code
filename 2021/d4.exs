inputs = File.read!("inputs/d4.dat")
test_inputs = File.read!("inputs/d4-test.dat")

defmodule S do
  def pre(str) do
    [nums | boards] =
      str
      |> String.split("\n\n")

    nums = nums |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)

    boards =
      boards
      |> Enum.map(fn b ->
        b
        |> String.split("\n")
        |> Enum.map(fn l ->
          l
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)
        end)
      end)

    {nums, boards}
  end

  def sol({nums, boards}) do
    t = :ets.new(:boards, [:set, :private])

    for {b, i} <- boards |> Enum.with_index() do
      for {row, y} <- b |> Enum.with_index() do
        for {v, x} <- row |> Enum.with_index() do
          :ets.insert(t, {{i, x, y, v}, nil})
        end
      end
    end

    {sum, n} =
      Enum.reduce_while(nums, nil, fn n, _ ->
        case mark_and_check(t, n) do
          nil ->
            {:cont, nil}

          sum ->
            {:halt, {sum, n}}
        end
      end)

    {sum, n, sum * n}
  end

  def match(t, p) do
    for [x] <- :ets.match(t, p) do
      x
    end
  end

  def mark_and_check(t, n) do
    :ets.match_object(t, {{:"$1", :"$2", :"$3", n}, :"$4"})
    |> Enum.sort()
    |> Enum.reduce_while(nil, fn {{b, x, y, ^n}, _m}, _ ->
      :ets.insert(t, {{b, x, y, n}, true})

      if Enum.all?(match(t, {{b, x, :_, :_}, :"$1"})) or
           Enum.all?(match(t, {{b, :_, y, :_}, :"$1"})) do
        {:halt,
         match(t, {{b, :_, :_, :"$1"}, nil})
         |> Enum.sum()}
      else
        {:cont, nil}
      end
    end)
  end
end

test_expect = {188, 24, 4512}

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
