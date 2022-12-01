inputs = File.read!("inputs/d9.dat")
test_inputs = File.read!("inputs/d9-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
      |> Enum.map(fn c -> c - ?0 end)
    end)
  end

  def sol(grid) do
    t = :ets.new(:grid, [:set])

    for {line, y} <- grid |> Enum.with_index() do
      for {v, x} <- line |> Enum.with_index() do
        :ets.insert_new(t, {{x, y}, v})
      end
    end

    dfs(t, [:ets.first(t)], 0, [])
    |> Enum.sort_by(& &1, :desc)
    |> Enum.take(3)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def dfs(t, [{x, y} | search], size, basins) do
    {add, search} =
      case :ets.lookup(t, k = {x, y}) do
        [{^k, 9}] ->
          {0, search}

        [{^k, _}] ->
          {1, adjusts(x, y) ++ search}

        [] ->
          {0, search}
      end

    :ets.delete(t, k)

    dfs(t, search, size + add, basins)
  end

  def dfs(t, [], size, basins) do
    case :ets.first(t) do
      :"$end_of_table" ->
        basins

      {x, y} ->
        dfs(t, [{x, y}], 0, [size | basins])
    end
  end

  defp adjusts(x, y) do
    [
      {x, y - 1},
      {x, y + 1},
      {x - 1, y},
      {x + 1, y}
    ]
  end
end

test_expect = 1134

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
