inputs = File.read!("inputs/d2.dat")
test_inputs = File.read!("inputs/d2-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n")
    |> Enum.map(fn s ->
      [m, n] = String.split(s)
      {m, String.to_integer(n)}
    end)
  end

  def mov([{m, n} | t], ho, d) do
    {ho, d} =
      case m do
        "forward" ->
          {ho + n, d}

        "up" ->
          {ho, d - n}

        "down" ->
          {ho, d + n}
      end

    mov(t, ho, d)
  end

  def mov(_, ho, d) do
    ho * d
  end

  def sol(list), do: mov(list, 0, 0)
end

test_expect = 150

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.puts()
