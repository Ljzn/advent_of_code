inputs = File.read!("inputs/d16.dat")
test_inputs = File.read!("inputs/d16-test.dat")

defmodule S do
  def pre(str) do
    str
    |> Base.decode16!()
  end

  def sol(bin) do
    {p, _} = decode(bin)
    sum_version(p)
  end

  defp sum_version(%{version: v, data: d}) do
    v + sum_version(d)
  end

  defp sum_version(list) when is_list(list) do
    list
    |> Enum.map(&sum_version(&1))
    |> Enum.sum()
  end

  defp sum_version(_), do: 0

  def decode(<<version::3, type_id::3, rest::bits>>) do
    {data, rest} = decode_type(type_id, rest)
    {%{version: version, data: data}, rest}
  end

  defp decode_type(4, rest) do
    decode_literal(rest, <<>>)
  end

  defp decode_type(_, <<0::1, length::15, rest::bits>>) do
    <<subs::size(length)-bits, rest::bits>> = rest
    {decode_subs(subs, []), rest}
  end

  defp decode_type(_, <<1::1, length::11, rest::bits>>) do
    for _ <- 1..length, reduce: {[], rest} do
      {result, rest} ->
        {data, rest} = decode(rest)
        {[data | result], rest}
    end
  end

  defp decode_subs(<<>>, result), do: Enum.reverse(result)

  defp decode_subs(subs, result) do
    {data, rest} = decode(subs)
    decode_subs(rest, [data | result])
  end

  defp decode_literal(<<0::1, d::bits-size(4), rest::bits>>, r) do
    {<<r::bits, d::bits>>, rest}
  end

  defp decode_literal(<<1::1, d::bits-size(4), rest::bits>>, r) do
    decode_literal(rest, <<r::bits, d::bits>>)
  end
end

test_expect = 31

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
