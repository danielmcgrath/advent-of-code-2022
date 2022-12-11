defmodule CPU do
  defstruct buffer: [1]

  def push(cpu, val) do
    %CPU{cpu | buffer: cpu.buffer ++ [val]}
  end

  def check_signal(cpu, cycle) do
    cpu.buffer |> Enum.take(cycle) |> Enum.filter(fn op -> op != :noop end) |> Enum.sum()
  end
end

defmodule Challenge do
  defp parse_input(filename) do
    File.stream!(filename)
    |> Enum.reduce(%CPU{}, fn line, acc ->
      case String.trim(line) do
        "noop" ->
          CPU.push(acc, :noop)

        "addx " <> x ->
          {incr, _} = Integer.parse(x)
          acc |> CPU.push(:noop) |> CPU.push(incr)
      end
    end)
  end

  def check_part1(filename) do
    cpu = parse_input(filename)

    [20, 60, 100, 140, 180, 220]
    |> Enum.map(fn cycle -> CPU.check_signal(cpu, cycle) * cycle end)
    |> Enum.sum()
  end

  def check_part2(filename) do
    cpu = parse_input(filename)
    screen = Enum.to_list(0..239) |> Enum.chunk_every(40)

    Enum.map(screen, fn row ->
      Enum.with_index(row)
      |> Enum.reduce([], fn {cycle, index}, render ->
        register = CPU.check_signal(cpu, cycle + 1)
        sprite = [register - 1, register, register + 1]

        if index in sprite do
          render ++ ["#"]
        else
          render ++ ["."]
        end
      end)
    end)
    |> Enum.map(fn row -> Enum.join(row, "") end)
    |> Enum.join("\n")
  end
end

IO.puts("Part one (test): #{Challenge.check_part1("test_input.txt")}")
IO.puts("Part one: #{Challenge.check_part1("input.txt")}")
IO.puts("Part two (test): \n#{Challenge.check_part2("test_input.txt")}")
IO.puts("Part two: \n#{Challenge.check_part2("input.txt")}")
