defmodule Challenge do
  def ordered?(pair) do
    case pair do
      [[], []] ->
        nil

      [[_ | _], []] ->
        false

      [[], [_ | _]] ->
        true

      [[l | lr], [r | rr]] when is_integer(l) and is_integer(r) ->
        if l == r, do: ordered?([lr, rr]), else: l < r

      [[l | lr], [r | rr]] when is_list(l) and is_integer(r) ->
        ordered?([[l | lr], [[r] | rr]])

      [[l | lr], [r | rr]] when is_integer(l) and is_list(r) ->
        ordered?([[[l] | lr], [r | rr]])

      [[l | lr], [r | rr]] when is_list(l) and is_list(r) ->
        case ordered?([l, r]) do
          nil -> ordered?([lr, rr])
          res -> res
        end
    end
  end

  defp parse(input) do
    File.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      # You know what... sure.
      {list, _} = line |> String.trim() |> Code.eval_string()
      list
    end)
  end

  def check(input) do
    parse(input)
    |> Enum.chunk_every(2)
    |> Enum.map(&ordered?/1)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {correct, index}, acc ->
      if correct, do: acc + index + 1, else: acc
    end)
  end

  def decoder_key(input) do
    (parse(input) ++ [[[2]], [[6]]])
    |> Enum.sort(fn a, b ->
      ordered?([a, b])
    end)
    |> Enum.with_index()
    |> Enum.filter(fn {x, _} -> x == [[2]] or x == [[6]] end)
    |> Enum.map(fn {_, i} -> i + 1 end)
    |> Enum.product()
  end
end

IO.puts("Part one (test): #{Challenge.check("test_input.txt")}")
IO.puts("Part one: #{Challenge.check("input.txt")}")
IO.puts("Part two (test): #{Challenge.decoder_key("test_input.txt")}")
IO.puts("Part two: #{Challenge.decoder_key("input.txt")}")
