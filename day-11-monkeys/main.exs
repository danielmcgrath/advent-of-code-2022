defmodule Challenge do
  defp int(str) do
    {int, _} = Integer.parse(str)
    int
  end

  defp get_op(opstring) do
    [_, op, target] = Regex.run(~r/new = old (.) (\d+|old)/, opstring)

    fn old ->
      y = if target == "old", do: old, else: int(target)

      case op do
        "+" -> old + y
        "*" -> old * y
      end
    end
  end

  defp monkey(config) do
    parsed =
      config
      |> Enum.reduce(%{}, fn line, m ->
        case String.trim(line) do
          "Starting items: " <> items ->
            Map.put(m, :items, String.split(items, ", ") |> Enum.map(&int/1))

          "Operation: " <> op ->
            Map.put(m, :operation, op)

          "Test: divisible by " <> test ->
            Map.put(m, :divisor, int(test))

          "If true: throw to monkey " <> monkey ->
            Map.put(m, :t, int(monkey))

          "If false: throw to monkey " <> monkey ->
            Map.put(m, :f, int(monkey))

          _ ->
            m
        end
      end)

    %{
      items: parsed[:items],
      op: get_op(parsed[:operation]),
      divisor: parsed[:divisor],
      truthy: parsed[:t],
      falsey: parsed[:f],
      inspected: 0
    }
  end

  def check_monkey_business(filename, iterations, calm) do
    monkeys =
      File.read!(filename)
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.chunk_every(6)
      |> Enum.map(fn chunk -> monkey(chunk) end)

    mod_factor = Enum.reduce(monkeys, 1, fn m, f -> m.divisor * f end)

    0..(iterations - 1)
    |> Enum.reduce(monkeys, fn _, round ->
      round
      |> Enum.with_index()
      |> Enum.reduce(round, fn {_, index}, turn ->
        monkey = Enum.at(turn, index)

        Enum.reduce(monkey[:items], turn, fn item, acc ->
          new_item = rem(monkey[:op].(item), mod_factor)
          new_item = if calm, do: Integer.floor_div(new_item, 3), else: new_item

          new_monkey =
            case rem(new_item, monkey[:divisor]) do
              0 -> monkey[:truthy]
              _ -> monkey[:falsey]
            end

          acc
          |> List.update_at(index, fn m ->
            [_ | rest] = m[:items]
            %{m | items: rest, inspected: m.inspected + 1}
          end)
          |> List.update_at(new_monkey, fn m ->
            %{m | items: m[:items] ++ [new_item]}
          end)
        end)
      end)
    end)
    |> Enum.sort_by(fn x -> x.inspected end)
    |> Enum.take(-2)
    |> Enum.map(fn m -> m.inspected end)
    |> Enum.product()
  end
end

IO.puts("Part one (test): #{Challenge.check_monkey_business("test_input.txt", 20, true)}")
IO.puts("Part one: #{Challenge.check_monkey_business("input.txt", 20, true)}")
IO.puts("Part two: #{Challenge.check_monkey_business("input.txt", 10000, false)}")
