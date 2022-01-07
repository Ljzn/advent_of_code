# test
# Player 1 starting position: 4
# Player 2 starting position: 8

# input
# Player 1 starting position: 4
# Player 2 starting position: 2

defmodule S do
  defmodule Unit do
    defstruct [
      :position,
      :amount,
      :score,
      :final
    ]
  end

  defp put_units_of_step(store, step) do
    Enum.reduce(1..10, store, fn x, acc ->
      put_store(acc, x, step)
    end)
  end

  def sol(p1, p2) do
    store = %{}

    # a position b step can got scores
    store = Enum.reduce(1..21, store, fn x, acc -> put_units_of_step(acc, x) end)

    store
    |> Enum.sort()
    |> Enum.map(fn {{from, step}, v} ->
      IO.inspect(win_ways(v), label: "win_ways of win from position #{from}, after #{step} steps")
    end)

    store
    |> Enum.filter(fn {k, v} -> elem(k, 0) == 1 end)
    |> Enum.map(fn {k, v} -> {k, Enum.sort_by(v, fn x -> x.score end)} end)
    |> IO.inspect()

    # test
    0 = win_universes(store, 1, 1)
    27 = lose_universes(store, 1, 1)

    true =
      :math.pow(27, 2) ==
        win_universes(store, 1, 1) * 27 + win_universes(store, 1, 2) +
          lose_universes(store, 1, 2)

    true =
      :math.pow(27, 3) ==
        win_universes(store, 1, 1) * 27 * 27 + win_universes(store, 1, 2) * 27 +
          win_universes(store, 1, 3) +
          lose_universes(store, 1, 3)

    true =
      :math.pow(27, 4) ==
        win_universes(store, 1, 1) * 27 * 27 * 27 + win_universes(store, 1, 2) * 27 * 27 +
          win_universes(store, 1, 3) * 27 + win_universes(store, 1, 4) +
          lose_universes(store, 1, 4)

    # for x <- 1..27 do
    #   a = lose_universes(store, 1, x)
    #   b = lose_universes2(store, 1, x)

    #   ^a = b
    # end

    # p1 win at n step
    {
      2..21
      |> Enum.map(fn s ->
        p1_universe(store, p1, p2, s)
      end)
      |> Enum.sum(),

      # p2 win at n step
      2..21
      |> Enum.map(fn s ->
        p2_universe(store, p1, p2, s)
      end)
      |> Enum.sum()
    }
  end

  defp p1_universe(store, p1, p2, step) do
    win_universes(store, p1, step) * lose_universes(store, p2, step - 1)
  end

  def win_universes(store, pos, step) do
    Map.fetch!(store, {pos, step})
    |> win_ways()
    |> tap(fn x -> IO.puts("win universes of pos #{pos} on step #{step} is #{x}") end)
  end

  # This is wrong method to calculate the lose universes, but I don't know why
  def lose_universes2(store, pos, step) do
    Enum.reduce(1..step, trunc(:math.pow(27, step)), fn x, acc ->
      acc - win_universes(store, pos, x) * trunc(:math.pow(27, step - x))
    end)
    |> tap(fn x -> IO.puts("lose universes2 of pos #{pos} on step #{step} is #{x}") end)
  end

  def lose_universes(store, pos, step) do
    Map.fetch!(store, {pos, step})
    |> lose_ways()
    |> tap(fn x -> IO.puts("lose universes of pos #{pos} on step #{step} is #{x}") end)
  end

  defp p2_universe(store, p1, p2, step) do
    win_universes(store, p2, step) * lose_universes(store, p1, step)
  end

  defp win_ways(units) do
    units
    |> Enum.filter(fn u -> u.final end)
    |> Enum.map(fn u -> u.amount end)
    |> Enum.sum()
  end

  defp lose_ways(units) do
    units
    |> Enum.reject(fn u -> u.final end)
    |> Enum.map(fn u -> u.amount end)
    |> Enum.sum()
  end

  defp padd(a, b) do
    rem(a + b - 1, 10) + 1
  end

  defp unit(pos, score, amount) do
    final = score >= 21

    %Unit{
      position: pos,
      score: score,
      amount: amount,
      final: final
    }
  end

  defp put_store(s, p, 1) do
    dices =
      for a <- 1..3, b <- 1..3, c <- 1..3 do
        a + b + c
      end

    27 = length(dices)

    units =
      dices
      |> Enum.reduce([], fn x, acc ->
        p = padd(p, x)
        [unit(p, p, 1) | acc]
      end)

    Map.put_new(s, {p, 1}, units)
  end

  defp put_store(s, p, steps) do
    units =
      for %Unit{position: p1, score: s1, amount: a1, final: false} <-
            Map.fetch!(s, {p, steps - 1}) do
        for %Unit{position: p2, score: s2, amount: a2, final: false} <-
              Map.fetch!(s, {p1, 1}) do
          unit(p2, s1 + s2, a1 * a2)
        end
      end
      |> List.flatten()
      |> Enum.group_by(fn u -> {u.position, u.score, u.final} end)
      |> Enum.map(fn {{pos, score, final}, us} ->
        %Unit{
          position: pos,
          score: score,
          amount: Enum.reduce(us, 0, fn u, acc -> u.amount + acc end),
          final: final
        }
      end)

    true = win_ways(units) < :math.pow(27, steps)

    Map.put_new(s, {p, steps}, units)
  end
end

# test
{444_356_092_776_315, 341_960_390_180_808} =
  S.sol(4, 8)
  |> IO.inspect(label: "test")

# p1
S.sol(4, 2)
|> IO.inspect()
