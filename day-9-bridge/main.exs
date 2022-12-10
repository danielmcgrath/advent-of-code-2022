defmodule Point do
  defstruct [:x, :y]

  defp update(point, field, inc) do
    Map.update!(point, field, fn v -> v + inc end)
  end

  def move(point, delta) do
    {x, y} = delta
    point |> update(:x, x) |> update(:y, y)
  end
end

defmodule Bridge do
  defstruct history: MapSet.new([%Point{x: 0, y: 0}]), knots: [], size: 0

  def new(num_knots) do
    %Bridge{knots: List.duplicate(%Point{x: 0, y: 0}, num_knots), size: num_knots}
  end

  def move_head(head, direction) do
    Point.move(
      head,
      case direction do
        "U" -> {0, 1}
        "R" -> {1, 0}
        "D" -> {0, -1}
        "L" -> {-1, 0}
      end
    )
  end

  def move_knot(leader, knot) do
    direction =
      case {leader.x - knot.x, leader.y - knot.y} do
        {0, 2} -> {0, 1}
        x when x in [{2, 2}, {1, 2}, {2, 1}] -> {1, 1}
        {2, 0} -> {1, 0}
        x when x in [{2, -2}, {2, -1}, {1, -2}] -> {1, -1}
        {0, -2} -> {0, -1}
        x when x in [{-2, -2}, {-1, -2}, {-2, -1}] -> {-1, -1}
        {-2, 0} -> {-1, 0}
        x when x in [{-2, 2}, {-2, 1}, {-1, 2}] -> {-1, 1}
        _ -> {0, 0}
      end

    {direction != nil, Point.move(knot, direction)}
  end

  def move(bridge, cmd) do
    [direction, countstr] = String.split(cmd, " ", trim: true)
    {count, _rem} = Integer.parse(countstr)

    1..count
    |> Enum.reduce(bridge, fn _, acc ->
      [head | rest] = acc.knots
      new_head = move_head(head, direction)

      Enum.reduce_while(
        acc.knots |> Enum.with_index(),
        %Bridge{acc | knots: [new_head | rest]},
        fn {knot, index}, acc1 ->
          {moved, new_point} = move_knot(Enum.at(acc1.knots, index - 1), knot)

          cond do
            index == 0 ->
              {:cont, acc1}

            !moved ->
              {:halt, acc1}

            true ->
              history =
                if index == acc1.size - 1,
                  do: MapSet.put(acc1.history, new_point),
                  else: acc1.history

              {:cont,
               %Bridge{
                 acc1
                 | knots: List.update_at(acc1.knots, index, fn _ -> new_point end),
                   history: history
               }}
          end
        end
      )
    end)
  end

  def check(filename, knots) do
    result =
      File.stream!(filename)
      |> Enum.reduce(Bridge.new(knots), fn line, bridge ->
        Bridge.move(bridge, line)
      end)

    result.history |> MapSet.size()
  end
end

IO.puts("Part one (test): #{Bridge.check("test_input.txt", 2)}")
IO.puts("Part one: #{Bridge.check("input.txt", 2)}")
IO.puts("Part two (test): #{Bridge.check("test_input_2.txt", 10)}")
IO.puts("Part two: #{Bridge.check("input.txt", 10)}")
