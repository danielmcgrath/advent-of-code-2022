defmodule Regolith do
  defp free?(map, grains, {x, y}, floor) do
    cond do
      floor != nil and y == floor ->
        false

      {x, y} not in MapSet.union(map, grains) ->
        true

      true ->
        false
    end
  end

  defp max_y(map) do
    map |> Enum.to_list() |> Enum.map(fn {_, y} -> y end) |> Enum.max()
  end

  defp is_overflow?(map, {_, y}) do
    y > max_y(map)
  end

  defp advance(map, grain, grains, floor) do
    {x, y} = grain

    cond do
      floor == nil and is_overflow?(map, grain) -> MapSet.size(grains)
      free?(map, grains, {x, y + 1}, floor) -> advance(map, {x, y + 1}, grains, floor)
      free?(map, grains, {x - 1, y + 1}, floor) -> advance(map, {x - 1, y + 1}, grains, floor)
      free?(map, grains, {x + 1, y + 1}, floor) -> advance(map, {x + 1, y + 1}, grains, floor)
      {x, y} == {500, 0} -> MapSet.size(grains) + 1
      true -> advance(map, {500, 0}, MapSet.put(grains, {x, y}), floor)
    end
  end

  defp advance(map, floor \\ nil) do
    advance(map, {500, 0}, MapSet.new(), floor)
  end

  defp parse_line(line) do
    xys =
      String.split(line, " -> ", trim: true)
      |> Enum.map(fn v ->
        String.split(v, ",")
        |> Enum.map(fn v ->
          Integer.parse(v) |> elem(0)
        end)
        |> List.to_tuple()
      end)

    xys
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {{x, y}, idx}, acc ->
      if idx == length(s) - 1 do
        MapSet.put(acc, {x, y})
      else
        {next_x, next_y} = Enum.at(s, idx + 1)

        cond do
          next_x == x ->
            y..next_y
            |> Enum.to_list()
            |> Enum.reduce(acc, fn v, a ->
              MapSet.put(a, {x, v})
            end)

          next_y == y ->
            x..next_x
            |> Enum.to_list()
            |> Enum.reduce(acc, fn v, a ->
              MapSet.put(a, {v, y})
            end)
        end
      end
    end)
  end

  defp parse_input(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(MapSet.new(), fn a, acc ->
      Enum.reduce(a, acc, fn p, acc1 -> MapSet.put(acc1, p) end)
    end)
  end

  def part_one(filename) do
    parse_input(filename) |> advance
  end

  def part_two(filename) do
    map = parse_input(filename)
    advance(map, max_y(map) + 2)
  end
end

IO.puts("Part one (test): #{Regolith.part_one("test_input.txt")}")
IO.puts("Part one: #{Regolith.part_one("input.txt")}")
IO.puts("Part two (test): #{Regolith.part_two("test_input.txt")}")
IO.puts("Part two: #{Regolith.part_two("input.txt")}")
