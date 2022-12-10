defmodule Treehouse do
  defp obscured?(grid, x, y) do
    row = grid |> Enum.at(y)
    height = row |> Enum.at(x)
    column = Enum.map(grid, fn row -> Enum.at(row, x) end)

    cond do
      Enum.take(row, x) |> Enum.max() < height -> false
      Enum.take(row, (length(row) - 1 - x) * -1) |> Enum.max() < height -> false
      Enum.take(column, y) |> Enum.max() < height -> false
      Enum.take(column, (length(column) - 1 - y) * -1) |> Enum.max() < height -> false
      true -> true
    end
  end

  defp is_visible(grid, x, y) do
    gridheight = length(grid) - 1
    gridwidth = length(Enum.at(grid, 0)) - 1

    case {x, y} do
      {x, _} when x in [0, gridwidth] -> true
      {_, y} when y in [0, gridheight] -> true
      _ -> !obscured?(grid, x, y)
    end
  end

  defp cast(trees, height) do
    Enum.reduce_while(trees, 0, fn c, acc ->
      if c >= height, do: {:halt, acc + 1}, else: {:cont, acc + 1}
    end)
  end

  defp get_scenic_score(grid, x, y) do
    row = grid |> Enum.at(y)
    height = row |> Enum.at(x)
    column = Enum.map(grid, fn row -> Enum.at(row, x) end)

    left = Enum.take(row, x) |> Enum.reverse() |> cast(height)
    right = Enum.take(row, (length(row) - 1 - x) * -1) |> cast(height)
    up = Enum.take(column, y) |> Enum.reverse() |> cast(height)
    down = Enum.take(column, (length(column) - 1 - y) * -1) |> cast(height)
    left * right * down * up
  end

  def find_visible_trees(filename) do
    grid =
      File.stream!(filename)
      |> Enum.reduce([], fn line, acc ->
        acc ++
          [
            line
            |> String.trim()
            |> String.split("", trim: true)
            |> Enum.map(fn s ->
              {int, _rem} = Integer.parse(s)
              int
            end)
          ]
      end)

    grid
    |> Enum.with_index()
    |> Enum.reduce(0, fn {row, y}, acc ->
      acc +
        (row
         |> Enum.with_index()
         |> Enum.reduce(0, fn {_cell, x}, a -> if is_visible(grid, x, y), do: a + 1, else: a end))
    end)
  end

  def find_most_scenic_tree(filename) do
    grid =
      File.stream!(filename)
      |> Enum.reduce([], fn line, acc ->
        acc ++
          [
            line
            |> String.trim()
            |> String.split("", trim: true)
            |> Enum.map(fn s ->
              {int, _rem} = Integer.parse(s)
              int
            end)
          ]
      end)

    grid
    |> Enum.with_index()
    |> Enum.reduce(0, fn {row, y}, acc ->
      Enum.max([
        acc,
        row
        |> Enum.with_index()
        |> Enum.reduce(0, fn {_cell, x}, a ->
          Enum.max([a, get_scenic_score(grid, x, y)])
        end)
      ])
    end)
  end
end

IO.puts("Part one (test): #{Treehouse.find_visible_trees("test_input.txt")}")
IO.puts("Part one: #{Treehouse.find_visible_trees("input.txt")}")
IO.puts("Part two (test): #{Treehouse.find_most_scenic_tree("test_input.txt")}")
IO.puts("Part two: #{Treehouse.find_most_scenic_tree("input.txt")}")
