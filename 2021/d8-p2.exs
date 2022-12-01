inputs = File.read!("inputs/d8.dat")
test_inputs = File.read!("inputs/d8-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split(["|", "\n"], trim: true)
    |> Enum.map(fn x ->
      x
      |> String.split(" ", trim: true)
    end)
    |> Enum.chunk_every(2)
  end

  def sol(list) do
    lines =
      for [input, output] <- list do
        {input |> Enum.map(&String.to_charlist/1), output |> Enum.map(&String.to_charlist/1)}
      end

    connectors = connector()

    for {input, output} <- lines do
      conn =
        Enum.reduce_while(connectors, nil, fn conn, _ ->
          if Enum.all?(input ++ output, fn w -> valid?(w, conn) end) do
            {:halt, conn}
          else
            {:cont, nil}
          end
        end)

      if conn == nil, do: raise("no valid connector find")

      for w <- output do
        to_digit(w, conn)
      end
      |> Enum.join()
      |> String.to_integer()
    end
    |> Enum.sum()
  end

  def to_digit(w, conn) do
    valid?(w, conn)
    |> to_string()
  end

  def connector do
    for a <- 0..6,
        b <- 0..6,
        b != a,
        c <- 0..6,
        c not in [a, b],
        d <- 0..6,
        d not in [a, b, c],
        e <- 0..6,
        e not in [a, b, c, d],
        f <- 0..6,
        f not in [a, b, c, d, e],
        g <- 0..6,
        g not in [a, b, c, d, e, f] do
      %{?a => a, ?b => b, ?c => c, ?d => d, ?e => e, ?f => f, ?g => g}
    end
  end

  defp valid?(w, conn) when is_map(conn) do
    for c <- w, reduce: 0 do
      acc -> acc + Bitwise.<<<(1, Map.fetch!(conn, c))
    end
    |> do_valid()
  end

  #   0
  #  1  2
  #   3
  #  4  5
  #   6

  for {num, schema} <- [
        {1, [2, 5]},
        {7, [0, 2, 5]},
        {4, [1, 2, 3, 5]},
        {8, [0, 1, 2, 3, 4, 5, 6]},
        {2, [0, 2, 3, 4, 6]},
        {3, [0, 2, 3, 5, 6]},
        {5, [0, 1, 3, 5, 6]},
        {6, [0, 1, 3, 4, 5, 6]},
        {9, [0, 1, 2, 3, 5, 6]},
        {0, [0, 1, 2, 4, 5, 6]}
      ] do
    n =
      for x <- schema, reduce: 0 do
        acc -> acc + Bitwise.<<<(1, x)
      end

    def do_valid(unquote(n)), do: unquote(num)
  end

  def do_valid(_), do: false
end

test_expect = 61229

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
