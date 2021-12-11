inputs = File.read!("inputs/d11.dat")
test_inputs = File.read!("inputs/d11-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
      |> Enum.map(fn x -> x - ?0 end)
    end)
  end

  def sol(grid) do
    t = :ets.new(:grid, [:set])

    for {row, y} <- Enum.with_index(grid) do
      for {v, x} <- Enum.with_index(row) do
        :ets.insert_new(t, {{x, y}, v})
      end
    end

    init_tasks = init_tasks(t)

    Enum.reduce(1..100, 0, fn _, flashes ->
      step(t, init_tasks)

      (:ets.match_object(t, {:"$1", 0})
       |> Enum.count()) + flashes
    end)
  end

  defp init_tasks(t) do
    for {k, _} <- :ets.tab2list(t) do
      k
    end
  end

  defp step(t, []) do
    for {k, -1} <- :ets.match_object(t, {:"$1", -1}) do
      :ets.insert(t, {k, 0})
    end
  end

  defp step(t, tasks) do
    step(
      t,
      for k <- tasks, reduce: [] do
        acc ->
          case :ets.lookup(t, k) do
            [{^k, v}] ->
              case v do
                v when v in 0..8 ->
                  :ets.insert(t, {k, v + 1})
                  []

                9 ->
                  :ets.insert(t, {k, -1})
                  adjusts(k)

                -1 ->
                  []
              end

            [] ->
              []
          end ++ acc
      end
    )
  end

  defp adjusts({x, y}) do
    for a <- -1..1, b <- -1..1, not (a == 0 and b == 0) do
      {x + a, y + b}
    end
  end
end

test_expect = 1656

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
