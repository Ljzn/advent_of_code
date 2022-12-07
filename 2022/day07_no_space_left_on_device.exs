defmodule NoSpaceLeftOnDevice do
  def parse("$ cd " <> dir) do
    {:cd, dir}
  end

  def parse("$ ls") do
    :ls
  end

  def parse("dir " <> dir) do
    {:dir, dir}
  end

  def parse(file) do
    [size, filename] = String.split(file, " ")
    {:file, filename, String.to_integer(size)}
  end

  def flat_map([], m, _), do: m

  def flat_map([{:cd, ".."} | t], m, path) do
    flat_map(t, m, tl(path))
  end

  def flat_map([{:cd, dir} | t], m, path) do
    path = [dir | path]
    {t, m} = collect(t, path, m)
    flat_map(t, m, path)
  end

  defp collect([:ls | t], path, m), do: collect(t, path, m)
  defp collect([{:cd, _} | _] = l, _, m), do: {l, m}
  defp collect([], _, m), do: {[], m}

  defp collect([{:file, name, size} | t], path, m) do
    collect(t, path, Map.put(m, to_path([name | path]), size))
  end

  defp collect([{:dir, dir} | t], path, m) do
    collect(t, path, Map.put(m, to_path([dir | path]), nil))
  end

  defp to_path(list), do: Enum.reverse(list) |> Path.join()

  def get_size(map, path) do
    map
    |> Enum.filter(fn {k, v} -> v != nil and String.starts_with?(k, path) end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sum()
  end
end

case IO.gets("Input the part number (1 or 2):\n") do
  "1\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> String.split("\n", trim: true)
    |> Enum.map(&NoSpaceLeftOnDevice.parse/1)
    |> NoSpaceLeftOnDevice.flat_map(%{}, [])
    |> then(fn map ->
      dirs = map |> Enum.filter(fn {_k, v} -> is_nil(v) end) |> Enum.map(fn {k, _} -> k end)

      Enum.map(dirs, fn dir ->
        NoSpaceLeftOnDevice.get_size(map, dir)
      end)
      |> Enum.filter(fn s -> s <= 100_000 end)
      |> Enum.sum()
    end)
    |> inspect()
    |> IO.puts()

  "2\n" ->
    IO.stream(:line)
    |> Stream.take_while(&(&1 != "done\n"))
    |> Enum.join()
    |> String.split("\n", trim: true)
    |> Enum.map(&NoSpaceLeftOnDevice.parse/1)
    |> NoSpaceLeftOnDevice.flat_map(%{}, [])
    |> IO.inspect()
    |> then(fn map ->
      dirs = map |> Enum.filter(fn {_k, v} -> is_nil(v) end) |> Enum.map(fn {k, _} -> k end)

      Enum.map(["/" | dirs], fn dir ->
        NoSpaceLeftOnDevice.get_size(map, dir)
      end)
    end)
    |> then(fn sizes ->
      total = Enum.max(sizes)
      need_free = total - 40_000_000
      Enum.sort(sizes) |> Enum.find(fn x -> x >= need_free end)
    end)
    |> IO.puts()
end
