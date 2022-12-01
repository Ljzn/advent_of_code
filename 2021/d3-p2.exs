inputs = File.read!("inputs/d3.dat")
test_inputs = File.read!("inputs/d3-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n")
    |> Enum.map(fn s ->
      s
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def head(list) do
    for [h | _] <- list do
      h
    end
  end

  def mst(head) do
    ones = Enum.sum(head)
    half = length(head) / 2

    if ones >= half do
      1
    else
      0
    end
  end

  def filter(list, r, least \\ false)
  def filter([x], r, _), do: Enum.reverse(r) ++ x

  def filter(list, r, least) do
    mst =
      list
      |> head()
      |> mst()

    s =
      if least do
        -(mst - 1)
      else
        mst
      end

    filter(
      for [^s | t] <- list do
        t
      end,
      [s | r],
      least
    )
  end

  def oxy(list), do: filter(list, [])
  def co2(list), do: filter(list, [], true)

  def sol(list) do
    oxy = Integer.undigits(oxy(list), 2)
    co2 = Integer.undigits(co2(list), 2)
    {oxy, co2, oxy * co2}
  end
end

test_expect = {23, 10, 230}

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
