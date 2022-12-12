defmodule MonkeyInTheMiddle do
  def parse(str, :monkeys) do
    str
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse(&1, :monkey))
    |> Enum.into(%{})
  end

  def parse(str, :monkey) do
    [
      "Monkey " <> monkey,
      "  Starting items: " <> items,
      "  Operation: " <> op,
      "  Test: divisible by " <> test,
      "    If true: throw to monkey " <> t_monkey,
      "    If false: throw to monkey " <> f_monkey
    ] = String.split(str, "\n", trim: true)

    monkey = String.trim_trailing(monkey, ":")

    {parse(monkey, :id),
     %{
       items: parse(items, :items),
       op: parse(op, :op),
       d: parse(test, :id),
       test: parse(parse(test, :id), :test, parse(t_monkey, :id), parse(f_monkey, :id)),
       times: 0
     }}
  end

  def parse(str, :id), do: String.to_integer(str)

  def parse(str, :items),
    do: String.split(str, ", ", trim: true) |> Enum.map(&String.to_integer/1)

  def parse(str, :op) do
    {fun, []} =
      """
      fn old ->
        #{str}
        new
      end
      """
      |> Code.eval_string()

    fun
  end

  def parse(d, :test, t, f) do
    fn x ->
      if rem(x, d) == 0 do
        t
      else
        f
      end
    end
  end

  def round(state, rule \\ 1) do
    state
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reduce(state, fn i, acc ->
      monkey(acc, i, rule)
    end)
  end

  def preprocess(state) do
    ds = Enum.map(state, fn {_, %{d: d}} -> d end)

    Enum.map(state, fn {k, v = %{items: items}} ->
      items = Enum.map(items, fn i -> itod(ds, i) end)
      {k, Map.put(v, :items, items)}
    end)
    |> Enum.into(%{})
  end

  defp itod(ds, i) do
    Enum.map(ds, fn d ->
      {d, rem(i, d)}
    end)
    |> Enum.into(%{})
  end

  def monkey(state, i, 1) do
    %{items: items, op: op, test: test} = state[i]

    items
    |> Enum.reduce(state, fn x0, acc ->
      x1 = op.(x0) |> div(3)
      m = test.(x1)

      update(acc, i, m, x0, x1)
    end)
  end

  def monkey(state, i, 2) do
    %{items: items, op: op, test: test, d: d0} = state[i]

    items
    |> Enum.reduce(state, fn x0, acc ->
      x1 =
        Enum.map(x0, fn {d, r} ->
          {d, rem(op.(r), d)}
        end)
        |> Enum.into(%{})

      m = test.(x1[d0])

      update(acc, i, m, x0, x1)
    end)
  end

  defp update(state, m0, m1, i0, i1) do
    state
    |> update_in([m0, :items], fn items -> List.delete(items, i0) end)
    |> update_in([m0, :times], fn t -> t + 1 end)
    |> update_in([m1, :items], fn items -> [i1 | items] end)
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> MonkeyInTheMiddle.parse(:monkeys)
    |> then(fn state ->
      Enum.reduce(1..20, state, fn _, acc ->
        MonkeyInTheMiddle.round(acc)
      end)
    end)
    |> Enum.map(fn {_, %{times: t}} -> t end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(2)
    |> Enum.reduce(1, &(&1 * &2))
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> MonkeyInTheMiddle.parse(:monkeys)
    |> MonkeyInTheMiddle.preprocess()
    |> then(fn state ->
      Enum.reduce(1..10000, state, fn _, acc ->
        MonkeyInTheMiddle.round(acc, 2)
      end)
    end)
    |> Enum.map(fn {_, %{times: t}} -> t end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(2)
    |> Enum.reduce(1, &(&1 * &2))
    |> IO.puts()
end
