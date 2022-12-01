inputs = File.read!("inputs/d16.dat")

test_inputs = [
  {"D2FE28", 2021},
  {"C200B40A82", 3},
  {"04005AC33890", 54},
  {"880086C3E88112", 7},
  {"CE00C43D881120", 9},
  {"D8005AC2A8F0", 1},
  {"F600BC2D8F", 0},
  {"9C005AC2F8F0", 0},
  {"9C0141080250320F1802104A08", 1}
]

defmodule S do
  def pre(str) do
    str
    |> Base.decode16!()
  end

  def sol(bin) do
    {p, _} = decode(bin)
    IO.inspect(p)
    p.value
  end

  def decode(<<version::3, type_id::3, rest::bits>>) do
    {data, rest} = decode_type(type_id, rest)
    {%{version: version, type_id: type_id, data: data} |> eval(), rest}
  end

  defp eval(%{type_id: 0, data: data} = p) do
    Map.put(p, :value, Enum.sum(data |> Enum.map(fn x -> x.value end)))
  end

  defp eval(%{type_id: 1, data: data} = p) do
    Map.put(p, :value, Enum.reduce(data |> Enum.map(fn x -> x.value end), &Kernel.*/2))
  end

  defp eval(%{type_id: 2, data: data} = p) do
    Map.put(p, :value, Enum.min(data |> Enum.map(fn x -> x.value end)))
  end

  defp eval(%{type_id: 3, data: data} = p) do
    Map.put(p, :value, Enum.max(data |> Enum.map(fn x -> x.value end)))
  end

  defp eval(%{type_id: 4, data: data} = p) do
    s = bit_size(data)
    <<v::size(s)>> = data
    Map.put(p, :value, v) |> Map.put(:literal, data)
  end

  defp eval(%{type_id: 5, data: data} = p) do
    [a, b] = data |> Enum.map(fn x -> x.value end)

    v =
      if a > b do
        1
      else
        0
      end

    Map.put(p, :value, v)
  end

  defp eval(%{type_id: 6, data: data} = p) do
    [a, b] = data |> Enum.map(fn x -> x.value end)

    v =
      if a < b do
        1
      else
        0
      end

    Map.put(p, :value, v)
  end

  defp eval(%{type_id: 7, data: data} = p) do
    [a, b] = data |> Enum.map(fn x -> x.value end)

    v =
      if a == b do
        1
      else
        0
      end

    Map.put(p, :value, v)
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
        {result ++ [data], rest}
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

for {t, e} <- test_inputs do
  ^e =
    t
    |> S.pre()
    |> S.sol()
end

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
