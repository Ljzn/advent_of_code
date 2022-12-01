inputs = File.read!("inputs/d13.dat")
test_inputs = File.read!("inputs/d13-test.dat")

defmodule S do
  def pre(str) do
    [grid, command] =
      str
      |> String.split("\n\n", trim: true)

    grid =
      grid
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [a, b] =
          line
          |> String.split(",")

        {{String.to_integer(a), String.to_integer(b)}, 1}
      end)
      |> Enum.into(%{})

    command =
      command
      |> String.split("\n", trim: true)
      |> Enum.map(fn
        "fold along x=" <> x ->
          {:x, String.to_integer(x)}

        "fold along y=" <> y ->
          {:y, String.to_integer(y)}
      end)

    {grid, command}
  end

  def sol({grid, command}) do
    grid =
      for c <- Enum.take(command, 1), reduce: grid do
        acc ->
          case c do
            {:x, x} ->
              for {{x0, y0}, v} <- acc do
                pos =
                  if x0 <= x do
                    {x0, y0}
                  else
                    {2 * x - x0, y0}
                  end

                {pos, v}
              end

            {:y, y} ->
              for {{x0, y0}, v} <- acc do
                pos =
                  if y0 <= y do
                    {x0, y0}
                  else
                    {x0, 2 * y - y0}
                  end

                {pos, v}
              end
          end
          |> Enum.reduce(%{}, fn {k, v}, acc ->
            Map.update(acc, k, v, fn v0 -> v0 + v end)
          end)
      end
      |> IO.inspect()

    Map.keys(grid) |> length()
  end
end

test_expect = 17

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
