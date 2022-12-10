defmodule SectionPairs do
  def unsafe_toint(s) do
    {int, _rem} = Integer.parse(s)
    int
  end

  def parse_pair(str) do
    String.split(str, ",")
    |> Enum.map(fn section ->
      String.split(section, "-") |> Enum.map(fn num -> unsafe_toint(num) end)
    end)
  end

  def to_range(section) do
    Enum.at(section, 0)..Enum.at(section, 1)
  end

  def contains(pair1, pair2) do
    Enum.at(pair1, 0) <= Enum.at(pair2, 0) && Enum.at(pair1, 1) >= Enum.at(pair2, 1)
  end

  def is_fully_contained(pair) do
    [first, second] = parse_pair(pair)
    contains(first, second) || contains(second, first)
  end

  def has_overlap(pair) do
    [first, second] = parse_pair(pair)
    !Range.disjoint?(to_range(first), to_range(second))
  end

  def check_containment(filename) do
    File.stream!(filename)
    |> Enum.filter(fn pair -> is_fully_contained(pair) end)
    |> length
  end

  def check_overlap(filename) do
    File.stream!(filename)
    |> Enum.filter(fn pair -> has_overlap(pair) end)
    |> length
  end
end

IO.puts("Part 1 test: #{SectionPairs.check_containment("test_input.txt")}")
IO.puts("Part 1 real: #{SectionPairs.check_containment("input.txt")}")
IO.puts("Part 2 test: #{SectionPairs.check_overlap("test_input.txt")}")
IO.puts("Part 2 real: #{SectionPairs.check_overlap("input.txt")}")
