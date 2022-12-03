defmodule PriorityPhaseOne do
  def midpoint(str) do
    str
      |> String.length
      |> Integer.floor_div(2)
  end

  def split(input) do
    input
      |> String.codepoints
      |> Enum.chunk_every(midpoint(input))
  end

  def priorities do
    lowers = for n <- ?a..?z, do: n
    uppers = for n <- ?A..?Z, do: n
    abcs = lowers ++ uppers |> Enum.map(fn (x) -> <<x :: utf8>> end)
    abcs |> Stream.zip(1..length(abcs)) |> Enum.into(%{})
  end

  def find_common_item_priority(rucksack, priorities) do
    [first, second] = rucksack |> split
    uniques = MapSet.new(first)
    dup = second |> Enum.find(fn (x) -> MapSet.member?(uniques, x) end)
    priorities[dup]
  end

  def check(input, priorities) do
    Enum.reduce(File.stream!(input), 0, fn (rucksack, priority) ->
      priority + find_common_item_priority(rucksack |> String.trim(), priorities)
    end)
  end
end

IO.puts("Phase 1 test: #{PriorityPhaseOne.check("test_input.txt", PriorityPhaseOne.priorities)}")
IO.puts("Phase 1 real: #{PriorityPhaseOne.check("input.txt", PriorityPhaseOne.priorities)}")
