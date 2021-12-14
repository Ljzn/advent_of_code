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
      for c <- command, reduce: grid do
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

    for x <- 0..50, y <- 0..10 do
      {{x, y}, 0}
    end
    |> Enum.into(%{})
    |> Map.merge(grid)
    |> Map.to_list()
    |> Enum.group_by(
      fn {{_x, y}, _v} ->
        y
      end,
      fn {{x, _y}, v} -> {x, v} end
    )
    |> Enum.sort()
    |> Enum.map(fn {_y, xs} ->
      for {x, v} <- xs do
        if v > 0 do
          {x, "#"}
        else
          {x, "."}
        end
      end
      |> Enum.sort()
      |> Enum.map(fn {_, v} -> v end)
      |> Enum.into("")
      |> IO.puts()
    end)
  end
end

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
