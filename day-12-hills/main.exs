defmodule HeightMap do
  defstruct [:grid, :heights]

  def new(str) do
    letters = for n <- ?a..?z, do: <<n::utf8>>
    heights = letters |> Stream.zip(1..length(letters)) |> Enum.into(%{})
    heights = heights |> Map.put("S", 1) |> Map.put("E", Map.get(heights, "z"))

    grid =
      str
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, "", trim: true)
        |> Enum.map(fn cell ->
          %{
            distance: if(cell == "S", do: 0, else: 999_999),
            value: cell,
            visited: false
          }
        end)
      end)

    %HeightMap{
      grid: grid,
      heights: heights
    }
  end

  def set_start(hm, [x, y]) do
    [current_x, current_y] = start(hm)

    %HeightMap{
      hm
      | grid:
          List.update_at(hm.grid, current_y, fn row ->
            List.update_at(row, current_x, fn cell -> %{cell | distance: 9999, value: "a"} end)
          end)
          |> List.update_at(y, fn row ->
            List.update_at(row, x, fn cell -> %{cell | distance: 0} end)
          end)
    }
  end

  def start(hm) do
    hm.grid
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, y}, acc ->
      row
      |> Enum.with_index()
      |> Enum.find(fn {v, i} -> if v.value == "S", do: i, else: false end)
      |> case do
        nil -> acc
        {_, x} -> [x, y]
      end
    end)
  end

  def ending(hm) do
    hm.grid
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, y}, acc ->
      row
      |> Enum.with_index()
      |> Enum.find(fn {v, i} -> if v.value == "E", do: i, else: false end)
      |> case do
        nil -> acc
        {_, x} -> [x, y]
      end
    end)
  end

  def at(hm, [x, y]) do
    hm.grid |> Enum.at(y) |> Enum.at(x)
  end

  def is_legal_move(hm, start, finish, reverse) do
    start_height = hm.heights[(hm |> at(start)).value]
    end_height = hm.heights[(hm |> at(finish)).value]

    if reverse do
      start_height - end_height < 2
    else
      end_height - start_height < 2
    end
  end

  def update(hm, a, b) do
    [x, y] = b
    a_node = hm |> at(a)
    b_node = hm |> at(b)
    distance = Enum.min([a_node.distance + 1, b_node.distance])

    %HeightMap{
      hm
      | grid:
          List.update_at(hm.grid, y, fn row ->
            List.update_at(row, x, fn cell -> %{cell | distance: distance} end)
          end)
    }
  end

  def mark_visited(hm, [x, y]) do
    %HeightMap{
      hm
      | grid:
          List.update_at(hm.grid, y, fn row ->
            List.update_at(row, x, fn cell -> %{cell | visited: true} end)
          end)
    }
  end

  def next_unvisited(hm) do
    unvisited =
      hm.grid
      |> Enum.with_index()
      |> Enum.map(fn {row, y_index} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {col, x_index} ->
          %{x: x_index, y: y_index, distance: col.distance, visited: col.visited}
        end)
      end)
      |> List.flatten()
      |> Enum.filter(fn v -> not v.visited end)

    if length(unvisited) == 0 do
      nil
    else
      lowest = Enum.min_by(unvisited, fn v -> v.distance end)
      [lowest.x, lowest.y]
    end
  end

  def neighbor(hm, point, direction) do
    [x, y] = point
    max_y = (hm.grid |> length) - 1
    max_x = (hm.grid |> Enum.at(0) |> length) - 1

    case {x, y, direction} do
      {_, 0, :up} -> nil
      {_, _, :up} -> [x, y - 1]
      {^max_x, _, :right} -> nil
      {_, _, :right} -> [x + 1, y]
      {_, ^max_y, :down} -> nil
      {_, _, :down} -> [x, y + 1]
      {0, _, :left} -> nil
      {_, _, :left} -> [x - 1, y]
    end
  end

  def walk(hm, point, reverse \\ false) do
    res =
      [:up, :right, :down, :left]
      |> Enum.reduce(hm, fn direction, acc ->
        acc
        |> neighbor(point, direction)
        |> case do
          nil ->
            acc

          target ->
            if is_legal_move(acc, point, target, reverse) do
              HeightMap.update(acc, point, target)
            else
              acc
            end
        end
      end)
      |> mark_visited(point)

    next = next_unvisited(res)

    if next == nil do
      res
    else
      walk(res, next, reverse)
    end
  end
end

defmodule HillClimbing do
  def find_shortest_path_from_start(input) do
    hm = File.read!(input) |> HeightMap.new()
    walked = HeightMap.walk(hm, HeightMap.start(hm))
    HeightMap.at(walked, HeightMap.ending(walked)).distance
  end

  def find_shortest_path_from_any_start(input) do
    hm = File.read!(input) |> HeightMap.new()
    original_ending = HeightMap.ending(hm)
    walked = hm |> HeightMap.set_start(original_ending) |> HeightMap.walk(original_ending, true)

    walked.grid
    |> List.flatten()
    |> Enum.reduce([], fn tile, acc ->
      if tile.value == "a" or tile.value == "S" do
        [tile.distance | acc]
      else
        acc
      end
    end)
    |> Enum.min()
  end
end

IO.puts("Part one (test): #{HillClimbing.find_shortest_path_from_start("test_input.txt")}")
IO.puts("Part one: #{HillClimbing.find_shortest_path_from_start("input.txt")}")
IO.puts("Part two (test): #{HillClimbing.find_shortest_path_from_any_start("test_input.txt")}")
IO.puts("Part two: #{HillClimbing.find_shortest_path_from_any_start("input.txt")}")
