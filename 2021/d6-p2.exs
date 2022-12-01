inputs = File.read!("inputs/d6.dat")
test_inputs = File.read!("inputs/d6-test.dat")

defmodule S do
  @days 256

  def pre(str) do
    str
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.group_by(& &1)
    |> Enum.map(fn {f, fs} -> {f, length(fs)} end)
  end

  def sol(fishes) do
    for _d <- 1..@days, reduce: fishes do
      fishes_acc ->
        for {f, n} <- fishes_acc, reduce: %{} do
          today_acc ->
            if f == 0 do
              Map.merge(today_acc, %{6 => n, 8 => n}, fn _k, v1, v2 -> v1 + v2 end)
            else
              Map.merge(today_acc, %{(f - 1) => n}, fn _k, v1, v2 -> v1 + v2 end)
            end
        end
    end
    |> Map.values()
    |> Enum.sum()
  end
end

test_expect = 26_984_457_539

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
