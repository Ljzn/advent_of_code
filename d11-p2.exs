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
    size = :ets.info(t, :size)

    Enum.reduce_while(Stream.cycle([0]), 1, fn _, n ->
      step(t, init_tasks)

      # easter egg
      print(t)

      case :ets.match_object(t, {:"$1", 0})
           |> Enum.count() do
        ^size ->
          {:halt, n}

        s when s < size ->
          {:cont, n + 1}
      end
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

  defp print(t) do
    es = :ets.tab2list(t)
    len = Enum.count(es, fn {{_x, y}, _} -> y == 0 end)

    es
    |> Enum.sort()
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.chunk_every(len)
    |> Enum.map(fn line -> Enum.join(line) end)
    |> Enum.join("\n")
    |> String.replace(~r/[1-9]/, ".")
    |> IO.puts()

    IO.puts("\n\n\n")
    :timer.sleep(50)
  end
end

test_expect = 195

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
