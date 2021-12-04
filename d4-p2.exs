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

    {b, sum, n} =
      Enum.reduce_while(nums, nil, fn n, _ ->
        case mark_and_check(t, n) do
          [] ->
            {:cont, nil}

          bss when is_list(bss) ->
            Enum.reduce_while(Enum.sort(bss), nil, fn {b, sum}, _ ->
              IO.inspect("board #{b} won, deleted")
              delete_board(t, b)

              if :ets.tab2list(t) == [] do
                {:halt, {:halt, {b, sum, n}}}
              else
                {:cont, {:cont, nil}}
              end
            end)
        end
      end)

    {b, sum, n, sum * n}
  end

  defp delete_board(t, b) do
    for o <- :ets.match_object(t, {{b, :"$1", :"$2", :"$3"}, :_}) do
      :ets.delete_object(t, o)
    end
  end

  def match(t, p) do
    for [x] <- :ets.match(t, p) do
      x
    end
  end

  def mark_and_check(t, n) do
    marks =
      :ets.match_object(t, {{:"$1", :"$2", :"$3", n}, :"$4"})
      |> Enum.map(fn {{b, x, y, ^n}, _} ->
        :ets.insert(t, {{b, x, y, n}, true})
        {b, x, y}
      end)

    marks
    |> Enum.sort()
    |> Enum.reduce_while([], fn {b, x, y}, acc ->
      if Enum.all?(match(t, {{b, x, :_, :_}, :"$1"})) or
           Enum.all?(match(t, {{b, :_, y, :_}, :"$1"})) do
        {:cont,
         [
           {b,
            match(t, {{b, :_, :_, :"$1"}, nil})
            |> Enum.sum()}
           | acc
         ]}
      else
        {:cont, acc}
      end
    end)
  end
end

test_expect = {1, 148, 13, 1924}

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
