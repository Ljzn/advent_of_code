inputs = File.read!("inputs/d6.dat")
test_inputs = File.read!("inputs/d6-test.dat")

defmodule S do
  @days 80

  def pre(str) do
    str
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def sol(fishes) do
    for _d <- 1..@days, reduce: fishes do
      fishes_acc ->
        for f <- fishes_acc, reduce: [] do
          today_acc ->
            if f == 0 do
              [6, 8 | today_acc]
            else
              [f - 1 | today_acc]
            end
        end
    end
    |> Enum.count()
  end
end

test_expect = 5934

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
