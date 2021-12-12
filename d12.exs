inputs = File.read!("inputs/d12.dat")
test_inputs = File.read!("inputs/d12-test.dat")

defmodule S do
  def pre(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [a, b] =
        line
        |> String.split("-")

      {a, b}
    end)
  end

  def sol(ps) do
    dfs(ps, [{"start", []}], 0)
  end

  defp dfs(_, [], r), do: r

  defp dfs(ps, tasks, r) do
    {new_tasks, add} =
      tasks
      |> Enum.map(&handle_task(ps, &1))
      |> List.flatten()
      |> reduce_result()

    dfs(ps, new_tasks, r + add)
  end

  defp handle_task(_, {"end", visited}) do
    IO.inspect(visited)
    :add
  end

  defp handle_task(ps, {cave, visited}) do
    visited =
      cond do
        Regex.match?(~r/[A-Z]/, cave) ->
          visited

        true ->
          [cave | visited]
      end

    (connect(ps, cave) -- visited)
    |> Enum.map(fn x -> {x, visited} end)
  end

  defp connect(ps, c) do
    ps
    |> Enum.map(fn
      {^c, x} ->
        x

      {x, ^c} ->
        x

      _ ->
        nil
    end)
    |> Enum.filter(& &1)
  end

  defp reduce_result(rs) do
    rs
    |> Enum.reduce({[], 0}, fn x, {t, r} ->
      case x do
        :add ->
          {t, r + 1}

        {_, _} ->
          {[x | t], r}
      end
    end)
  end
end

test_expect = 10

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
