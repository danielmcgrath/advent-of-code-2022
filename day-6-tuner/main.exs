defmodule Tuner do
  def is_unique?(packet) do
    length(Enum.uniq(packet)) == length(packet)
  end

  def find_marker(stream, len, index \\ 0) do
    cond do
      Enum.slice(stream, index..(index + len - 1)) |> is_unique? ->
        index + len
      true ->
        find_marker(stream, len, index + 1)
    end
  end

  def find_start_of_packet(stream) do
    String.split(stream, "", trim: true) |> find_marker(4)
  end

  def find_start_of_message(stream) do
    String.split(stream, "", trim: true) |> find_marker(14)
  end
end

IO.puts("Part one test: #{Tuner.find_start_of_packet("mjqjpqmgbljsphdztnvjfqwrcgsmlb")}")
IO.puts("Part one real: #{Tuner.find_start_of_packet(File.read!("input.txt"))}")
IO.puts("Part two test: #{Tuner.find_start_of_message("mjqjpqmgbljsphdztnvjfqwrcgsmlb")}")
IO.puts("Part two real: #{Tuner.find_start_of_message(File.read!("input.txt"))}")
