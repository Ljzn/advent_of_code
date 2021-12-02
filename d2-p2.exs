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

  def mov([{m, n} | t], ho, d, aim) do
    {ho, d, aim} =
      case m do
        "forward" ->
          {ho + n, d + aim * n, aim}

        "up" ->
          {ho, d, aim - n}

        "down" ->
          {ho, d, aim + n}
      end

    mov(t, ho, d, aim)
  end

  def mov(_, ho, d, _aim) do
    ho * d
  end

  def sol(list), do: mov(list, 0, 0, 0)
end

test_expect = 900

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.puts()
