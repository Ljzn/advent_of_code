inputs = File.read!("inputs/d5.dat")
test_inputs = File.read!("inputs/d5-test.dat")

defmodule S do
  def pre(str) do
    for line <-
          str
          |> String.split("\n", trim: true) do
      line
      |> String.split([",", " -> "], trim: true)
      |> Enum.map(&String.to_integer/1)
    end
  end

  def sol(lines) do
    t = :ets.new(:points, [:set])

    for line = [x1, y1, x2, y2] <- lines, x1 == x2 or y1 == y2 do
      for {x, y} <- points_on_line(line) do
        :ets.update_counter(t, {x, y}, 1, {{x, y}, 0})
      end
    end

    :ets.select(t, [
      {
        {:_, :"$1"},
        [
          {:>, :"$1", 1}
        ],
        [:"$_"]
      }
    ])
    |> Enum.count()
  end

  defp points_on_line([x1, y1, x2, y2]) do
    for x <- x1..x2, y <- y1..y2 do
      {x, y}
    end
  end
end

test_expect = 5

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
