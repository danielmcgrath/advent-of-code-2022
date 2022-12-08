defmodule FS do
  defstruct cwd: [], tree: %{}

  def new do
    %FS{}
  end

  def chdir(fs, dir) do
    case dir do
      "/" -> %FS{cwd: [], tree: fs.tree}
      "/" <> _ -> %FS{cwd: String.split(dir, "/", trim: true), tree: fs.tree}
      ".." -> %FS{cwd: Enum.drop(fs.cwd, -1), tree: fs.tree}
      _ -> %FS{cwd: fs.cwd ++ [dir], tree: fs.tree}
    end
  end

  def add_file(fs, name, size) do
    {size_int, _rem} = Integer.parse(size)
    %FS{cwd: fs.cwd, tree: put_in(fs.tree, fs.cwd ++ [String.trim(name)], size_int)}
  end

  def add_dir(fs, name) do
    %FS{cwd: fs.cwd, tree: put_in(fs.tree, fs.cwd ++ [String.trim(name)], %{})}
  end
end

defmodule Challenge do
  defp du(tree) do
    Enum.reduce(tree, %{}, fn ({key, value}, acc) ->
      cond do
        is_integer(value) ->
          Map.put(acc, :size, Map.get(acc, :size, 0) + value)
        is_map(value) ->
          subdir = du(value)
          Map.put(acc, key, subdir) |> Map.put(:size, Map.get(acc, :size, 0) + subdir[:size])
      end
    end)
  end

  defp build_filesystem(filename) do
    File.stream!(filename) |> Enum.reduce(FS.new, fn (line, fs) ->
      line |> String.trim |> case do
        "$ cd " <> dir ->
          FS.chdir(fs, dir)
        "dir" <> dir ->
          FS.add_dir(fs, dir)
        "$" <> _ ->
          fs
        _ ->
          [size, name] = String.split(line, " ", trim: true)
          FS.add_file(fs, name, size)
      end
    end)
  end

  defp find_freeable_space(sizes, max) do
    Enum.reduce(sizes, 0, fn ({key, value}, sum) ->
      cond do
        key == :size && value <= max ->
          sum + value
        key == :size && value > max ->
          sum
        true ->
          sum + find_freeable_space(value, max)
      end
    end)
  end

  defp candidate(tree, needed) do
    Enum.reduce(tree, nil, fn ({key, value}, acc) ->
      cond do
        key == :size && value >= needed -> Enum.min([acc, value])
        key == :size -> acc
        key != :size -> Enum.min([acc, candidate(value, needed)])
      end
    end)
  end

  def freeable_space(filename, max_dir_size) do
    build_filesystem(filename).tree
      |> du
      |> find_freeable_space(max_dir_size)
  end

  def find_deletion_candidate(filename, total_space, update_size) do
    sizes = build_filesystem(filename).tree |> du
    candidate(sizes, abs(total_space - update_size - sizes[:size]))
  end
end

IO.puts("Part one (test): #{Challenge.freeable_space("test_input.txt", 100000)}")
IO.puts("Part one: #{Challenge.freeable_space("input.txt", 100000)}")
IO.puts("Part two (test): #{Challenge.find_deletion_candidate("test_input.txt", 70000000, 30000000)}")
IO.puts("Part two: #{Challenge.find_deletion_candidate("input.txt", 70000000, 30000000)}")
