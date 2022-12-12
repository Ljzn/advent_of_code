defmodule CathodeRayTube do
  def parse("addx " <> i) do
    [:noop, {:add, String.to_integer(i)}]
  end

  def parse("noop"), do: :noop

  def exe([], _, _, ps), do: ps

  def exe([h | t], r, c, ps) do
    ps =
      if ps[c] do
        Map.put(ps, c, r)
      else
        ps
      end

    r =
      case h do
        {:add, i} ->
          r + i

        :noop ->
          r
      end

    exe(t, r, c + 1, ps)
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> then(fn str ->
      String.split(str, "\n", trim: true)
      |> Enum.map(&CathodeRayTube.parse/1)
      |> List.flatten()
    end)
    |> CathodeRayTube.exe(1, 1, %{
      20 => true,
      60 => true,
      100 => true,
      140 => true,
      180 => true,
      220 => true
    })
    |> IO.inspect()
    |> Enum.map(fn {k, v} -> k * v end)
    |> Enum.sum()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> then(fn str ->
      String.split(str, "\n", trim: true)
      |> Enum.map(&CathodeRayTube.parse/1)
      |> List.flatten()
    end)
    |> CathodeRayTube.exe(1, 1, 1..240 |> Enum.map(fn x -> {x, true} end) |> Enum.into(%{}))
    |> Enum.sort()
    # |> IO.inspect()
    |> Enum.map(fn {k, v} ->
      if rem(k - 1, 40) in (v - 1)..(v + 1) do
        {k, "#"}
      else
        {k, "."}
      end
    end)
    |> Enum.chunk_every(40)
    |> Enum.map(fn line ->
      Enum.map(line, fn {_, c} -> c end)
      |> Enum.into("")
      |> IO.puts()
    end)
end
