defmodule CaloriesPhaseOne do
  def collapse(res) do
    [[], Enum.max([Enum.at(res, 0) |> Enum.sum(), Enum.at(res, 1)])]
  end

  def check(file) do
    Enum.reduce(File.stream!(file), [[], 0], fn line, acc ->
      case String.trim(line) do
        "" ->
          collapse(acc)

        x ->
          {int, _remainder} = Integer.parse(x)
          [[int | Enum.at(acc, 0)], Enum.at(acc, 1)]
      end
    end)
    |> collapse
    |> Enum.at(1)
  end
end

defmodule CaloriesPhaseTwo do
  def collapse(x) do
    [[], [Enum.at(x, 0) |> Enum.sum() | Enum.at(x, 1)] |> Enum.sort(:desc) |> Enum.take(3)]
  end

  def check(input_path) do
    Enum.reduce(File.stream!(input_path), [[], []], fn line, acc ->
      case String.trim(line) do
        "" ->
          collapse(acc)

        x ->
          {int, _remainder} = Integer.parse(x)
          [[int | Enum.at(acc, 0)], Enum.at(acc, 1)]
      end
    end)
    |> collapse
    |> Enum.at(1)
    |> Enum.sum()
  end
end

IO.puts("Phase 1: #{CaloriesPhaseOne.check("input.txt") |> Integer.to_string()}")
IO.puts("Phase 2: #{CaloriesPhaseTwo.check("input.txt") |> Integer.to_string()}")
