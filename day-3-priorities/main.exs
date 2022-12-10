defmodule Priority do
  def midpoint(str) do
    str
    |> String.length()
    |> Integer.floor_div(2)
  end

  def split(input) do
    input
    |> String.codepoints()
    |> Enum.chunk_every(midpoint(input))
  end

  def priorities do
    lowers = for n <- ?a..?z, do: n
    uppers = for n <- ?A..?Z, do: n
    abcs = (lowers ++ uppers) |> Enum.map(fn x -> <<x::utf8>> end)
    abcs |> Stream.zip(1..length(abcs)) |> Enum.into(%{})
  end

  def find_common_item_priority(rucksack, priorities) do
    [first, second] = rucksack |> split
    uniques = MapSet.new(first)
    dup = second |> Enum.find(fn x -> MapSet.member?(uniques, x) end)
    priorities[dup]
  end

  def find_badge_priorities(rucksack_group, priorities) do
    badge =
      rucksack_group
      |> Enum.map(fn x -> MapSet.new(String.split(x, "", trim: true)) end)
      |> Enum.reduce(fn rs, acc -> MapSet.intersection(acc, rs) end)
      |> Enum.to_list()
      |> Enum.at(0)

    priorities[badge]
  end

  def check_part_one(input, priorities) do
    Enum.reduce(File.stream!(input), 0, fn rucksack, priority ->
      priority + find_common_item_priority(rucksack |> String.trim(), priorities)
    end)
  end

  def check_part_two(input, priorities) do
    File.read!(input)
    |> String.split("\n")
    |> Enum.chunk_every(3)
    |> Enum.map(fn group -> find_badge_priorities(group, priorities) end)
    |> Enum.sum()
  end
end

IO.puts("Phase 1 test: #{Priority.check_part_one("test_input.txt", Priority.priorities())}")
IO.puts("Phase 1 real: #{Priority.check_part_one("input.txt", Priority.priorities())}")
IO.puts("Phase 2 test: #{Priority.check_part_two("test_input.txt", Priority.priorities())}")
IO.puts("Phase 2 real: #{Priority.check_part_two("input.txt", Priority.priorities())}")
