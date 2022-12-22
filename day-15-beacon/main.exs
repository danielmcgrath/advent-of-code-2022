defmodule Beacons do
  defp parse(filename) do
    File.stream!(filename)
    |> Enum.reduce([], fn line, acc ->
      parsed =
        Regex.run(
          ~r/\w+ x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/,
          line
        )

      case parsed do
        [_, sx, sy, bx, by] ->
          acc ++ [[sx, sy, bx, by] |> Enum.map(&String.to_integer/1)]

        _ ->
          acc
      end
    end)
  end

  defp frequency({x, y}) do
    x * 4_000_000 + y
  end

  defp distance({sx, sy}, {bx, by}) do
    abs(sx - bx) + abs(sy - by)
  end

  defp check(sbs, range_max, x \\ 0, y \\ 0) do
    case Enum.find(sbs, fn sb -> occludes?(sb, {x, y}) end) do
      nil ->
        {x, y}

      [sx, sy, bx, by] ->
        with _..rx = xrange([sx, sy, bx, by], y, range_max) do
          cond do
            rx == range_max -> check(sbs, range_max, 0, y + 1)
            true -> check(sbs, range_max, rx + 1, y)
          end
        end
    end
  end

  defp occludes?([sx, sy, bx, by], {x, y}) do
    distance({sx, sy}, {x, y}) <= distance({sx, sy}, {bx, by})
  end

  defp xrange([sx, sy, bx, by], row, range_max) do
    d = distance({sx, sy}, {bx, by})
    max(sx - (d - abs(sy - row)), 0)..min(sx + (d - abs(sy - row)), range_max)
  end

  def unbeaconable(filename, row) do
    sbs = parse(filename)

    [xmin, xmax, dmax] =
      Enum.reduce(sbs, [0, 0, 0], fn [sx, sy, bx, by], acc ->
        [
          Enum.min([sx, bx, Enum.at(acc, 0)]),
          Enum.max([sx, bx, Enum.at(acc, 1)]),
          max(distance({sx, sy}, {bx, by}), Enum.at(acc, 2))
        ]
      end)

    (xmin - dmax)..(xmax + dmax)
    |> Enum.to_list()
    |> Enum.filter(fn x ->
      Enum.find(sbs, fn [_, _, bx, by] = sb ->
        if bx == x and by == row, do: false, else: occludes?(sb, {x, row})
      end)
    end)
    |> length
  end

  def locate(filename, range_max) do
    filename |> parse |> check(range_max) |> frequency
  end
end

IO.puts("Part one (test): #{Beacons.unbeaconable("test_input.txt", 10)}")
IO.puts("Part one: #{Beacons.unbeaconable("input.txt", 2_000_000)}")
IO.puts("Part two (test): #{Beacons.locate("test_input.txt", 20)}")
IO.puts("Part two: #{Beacons.locate("input.txt", 4_000_000)}")
