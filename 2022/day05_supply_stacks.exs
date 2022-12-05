defmodule SupplyStacks do
  defp move([h1 | s1], s2) do
    [s1, [h1 | s2]]
  end

  def move_stack(stacks, n, from, to) do
    Enum.reduce(1..n, stacks, fn _, acc ->
      move_stack(acc, from, to)
    end)
  end

  def move_stack(stacks, from, to) do
    [a, b] = move(stacks[from], stacks[to])
    Map.merge(stacks, %{from => a, to => b})
  end

  def move_stack_once(stacks, n, from, to) do
    s1 = stacks[from]
    s2 = stacks[to]
    {crates, s1} = Enum.split(s1, n)
    s2 = crates ++ s2
    Map.merge(stacks, %{from => s1, to => s2})
  end

  def parse(str, :stacks_and_steps) do
    [a, b] =
      str
      |> String.split("\n\n", trim: true)

    [parse(a, :stacks), parse(b, :steps)]
  end

  def parse(str, :stacks) do
    [ids | crates] =
      str
      |> String.split("\n", trim: true)
      |> Enum.reverse()

    ids = String.split(ids, " ", trim: true) |> Enum.map(&String.to_integer/1)

    pack_stacks(
      Enum.map(ids, fn id -> {id, []} end) |> Enum.into(%{}),
      Enum.map(crates, &parse(&1, :crates))
    )
  end

  def parse("", :crates), do: []

  def parse(str, :crates) do
    {crate, rest} = String.split_at(str, 3)
    {_, rest} = String.split_at(rest, 1)

    c =
      case crate do
        "   " -> nil
        "[" <> <<x::bytes-size(1)>> <> "]" -> x
      end

    [c | parse(rest, :crates)]
  end

  def parse(str, :steps) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse(&1, :step))
  end

  def parse(str, :step) do
    str
    |> String.split(["move ", " from ", " to "], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp pack_stacks(stacks, []), do: stacks

  defp pack_stacks(stacks, [bottom | crates]) do
    stacks =
      bottom
      |> Enum.with_index()
      |> Enum.reduce(stacks, fn {c, i}, acc ->
        if c do
          Map.update!(acc, i + 1, fn list -> [c | list] end)
        else
          acc
        end
      end)

    pack_stacks(stacks, crates)
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> SupplyStacks.parse(:stacks_and_steps)
    |> then(fn [stacks, steps] ->
      Enum.reduce(steps, stacks, fn step, acc ->
        apply(SupplyStacks, :move_stack, [acc | step])
      end)
    end)
    |> Enum.into([])
    |> Enum.sort()
    |> Enum.map(fn {_, [h | _]} -> h end)
    |> Enum.join()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> SupplyStacks.parse(:stacks_and_steps)
    |> then(fn [stacks, steps] ->
      Enum.reduce(steps, stacks, fn step, acc ->
        apply(SupplyStacks, :move_stack_once, [acc | step])
      end)
    end)
    |> Enum.into([])
    |> Enum.sort()
    |> Enum.map(fn {_, [h | _]} -> h end)
    |> Enum.join()
    |> IO.puts()
end
