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
    (dfs(ps, [{"start", []}], []) ++
       (shadow_ps(ps)
        |> Enum.map(fn p ->
          dfs(p, [{"start", []}], [])
          |> Enum.filter(&hit?/1)
          |> Enum.map(&unshadow/1)
          |> Enum.uniq()
        end)
        |> unwrap()))
    |> length()
  end

  defp unwrap(list) do
    for l <- list, reduce: [] do
      acc -> l ++ acc
    end
  end

  defp unshadow(list) do
    for x <- list do
      if String.ends_with?(x, "shadow") do
        String.trim_trailing(x, "shadow")
      else
        x
      end
    end
  end

  defp hit?(visited) do
    if s = Enum.find(visited, &String.ends_with?(&1, "shadow")) do
      ori = String.trim_trailing(s, "shadow")
      ori in visited
    end
  end

  defp shadow_ps(ps) do
    for s <- all_smalls(ps) do
      inject_shadow(ps, s)
    end
  end

  defp all_smalls(ps) do
    ps
    |> Enum.map(fn {a, b} -> [a, b] end)
    |> List.flatten()
    |> Enum.uniq()
    |> small_only()
  end

  defp small_only(list) do
    list
    |> Enum.filter(fn x ->
      x != "start" and x != "end" and Regex.match?(~r/[a-z]/, x)
    end)
  end

  defp inject_shadow(ps, s) do
    ps
    |> Enum.map(fn
      {^s, x} ->
        {s <> "shadow", x}

      {x, ^s} ->
        {x, s <> "shadow"}

      _ ->
        nil
    end)
    |> Enum.filter(& &1)
    |> Kernel.++(ps)
  end

  defp dfs(_, [], r), do: r

  defp dfs(ps, tasks, r) do
    {new_tasks, add} =
      tasks
      |> Enum.map(&handle_task(ps, &1))
      |> List.flatten()
      |> reduce_result()

    dfs(ps, new_tasks, add ++ r)
  end

  defp handle_task(_, {"end", visited}) do
    {:add, visited}
  end

  defp handle_task(ps, {cave, visited}) do
    visited = [cave | visited]

    connect(ps, cave)
    |> Kernel.--(small_only(visited))
    |> Kernel.--(["start"])
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
    |> Enum.uniq()
    |> Enum.filter(& &1)
  end

  defp reduce_result(rs) do
    rs
    |> Enum.reduce({[], []}, fn x, {t, r} ->
      case x do
        {:add, visited} ->
          {t, [visited | r]}

        {_, _} ->
          {[x | t], r}
      end
    end)
  end
end

test_expect = 36

^test_expect =
  test_inputs
  |> S.pre()
  |> S.sol()

inputs
|> S.pre()
|> S.sol()
|> IO.inspect()
