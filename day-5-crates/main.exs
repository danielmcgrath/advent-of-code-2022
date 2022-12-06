defmodule Stack do
  defstruct values: []

  def new do
    %Stack{}
  end

  def push(s, v) do
    %Stack{values: [v | s.values]}
  end

  def pop(%Stack{values: [v | rest]}) do
    {v, %Stack{values: rest}}
  end

  def popn(s, n) do
    [values, remaining] = Enum.with_index(s.values) |> Enum.reduce([[], []], fn ({v, idx}, acc) ->
      cond do
        idx < n -> [Enum.at(acc, 0) ++ [v], Enum.at(acc, 1)]
        idx >= n -> [Enum.at(acc, 0), Enum.at(acc, 1) ++ [v]]
      end
    end)

    [values, %Stack{values: remaining}]
  end

  def pushn(s, vs) do
    %Stack{values: vs ++ s.values}
  end
end

defmodule Crates do
  def unsafe_toint(s) do
    {int, _rem} = Integer.parse(s)
    int
  end

  def strip(cell) do
    Regex.replace(~r/\W+/, cell, "")
  end

  def init_stacks(stacks) do
    Enum.reduce(stacks, [], fn (rowstr, acc) ->
      row = rowstr |> String.codepoints |> Enum.chunk_every(4) |> Enum.map(&Enum.join/1)
      case length(acc) do
        0 -> Enum.map(row, fn (c) -> %Stack{values: [strip(c)]} end)
        _ -> row |> Enum.with_index |> Enum.map(fn {c, idx} ->
          value = strip(c)
          case value do
            "" -> Enum.at(acc, idx)
            _ -> Stack.push(Enum.at(acc, idx), strip(c))
          end
        end)
      end
    end)
  end

  def parse_plan(filename) do
    File.stream!(filename) |> Enum.reduce([[], []], fn (line, acc) ->
      cond do
        String.starts_with?(line, "move") ->
          [Enum.at(acc, 0), Enum.at(acc, 1) ++ [String.trim(line)]]
        String.contains?(line, "[") ->
          [[line |> String.trim("\n") | Enum.at(acc, 0)], Enum.at(acc, 1)]
        true ->
          acc
      end
    end)
  end

  def parse_move(m) do
    [_str | rest] = Regex.run(~r/move (\d+) from (\d+) to (\d+)/, m)
    [count, start_stack, end_stack] = Enum.map(rest, &unsafe_toint/1)
    [count, start_stack - 1, end_stack - 1]
  end

  def apply_moves(stacks, sequence) do
    Enum.reduce(sequence, stacks, fn (move, acc) ->
      [num_to_move, start_stack, end_stack] = parse_move(move)
      Enum.reduce_while(0..num_to_move, acc, fn (idx, inner_stacks) ->
        if idx == num_to_move do
          {:halt, inner_stacks}
        else
          {value, popped} = Stack.pop(Enum.at(inner_stacks, start_stack))
          pushed = Stack.push(Enum.at(inner_stacks, end_stack), value)
          {:cont, Enum.with_index(inner_stacks) |> Enum.map(fn {s, idx} ->
            case idx do
              ^start_stack -> popped
              ^end_stack -> pushed
              _ -> s
            end
          end)}
        end
      end)
    end)
  end

  def apply_moves_part_two(stacks, sequence) do
    Enum.reduce(sequence, stacks, fn (move, acc) ->
      [num_to_move, start_stack, end_stack] = parse_move(move)
      [values, popped] = Stack.popn(Enum.at(acc, start_stack), num_to_move)
      pushed = Stack.pushn(Enum.at(acc, end_stack), values)
      acc |> List.replace_at(start_stack, popped) |> List.replace_at(end_stack, pushed)
    end)
  end

  def find_stack_toppers(filename) do
    [stacks, sequence] = parse_plan(filename)
    init_stacks(stacks) |> apply_moves(sequence) |> Enum.map(fn (stack) ->
      {value, _stack} = Stack.pop(stack)
      value
    end) |> Enum.join("")
  end

  def find_stack_toppers_part_two(filename) do
    [stacks, sequence] = parse_plan(filename)
    init_stacks(stacks) |> apply_moves_part_two(sequence) |> Enum.map(fn (stack) ->
      {value, _stack} = Stack.pop(stack)
      value
    end) |> Enum.join("")
  end
end

IO.puts("Part one (test): #{Crates.find_stack_toppers("test_input.txt")}")
IO.puts("part one (real): #{Crates.find_stack_toppers("input.txt")}")
IO.puts("Part two (test): #{Crates.find_stack_toppers_part_two("test_input.txt")}")
IO.puts("part two (real): #{Crates.find_stack_toppers_part_two("input.txt")}")
