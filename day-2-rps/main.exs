defmodule Option do
  def from_v1_input(i) do
    case i do
      v when v in ["A", "X"] -> :rock
      v when v in ["B", "Y"] -> :paper
      v when v in ["C", "Z"] -> :scissors
    end
  end

  def from_v2_input(i) do
    case i do
      "A" -> :rock
      "B" -> :paper
      "C" -> :scissors
    end
  end

  def score(option) do
    case option do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end
  end
end

defmodule RPSPart1 do
  def outcome_score(their_choice, our_choice) do
    case {their_choice, our_choice} do
      {:scissors, :rock} -> 6
      {:rock, :paper} -> 6
      {:paper, :scissors} -> 6
      {x, x} -> 3
      _ -> 0
    end
  end

  def check(input) do
    Enum.reduce(File.stream!(input), 0, fn (line, acc) ->
      [theirs, ours | _] = String.trim(line) |> String.split(" ") |> Enum.map(fn (x) -> Option.from_v1_input(x) end)
      acc + outcome_score(theirs, ours) + Option.score(ours)
    end)
  end
end

defmodule RPSPart2 do
  def outcome_score(desired_outcome) do
    case desired_outcome do
      :lose -> 0
      :draw -> 3
      :win -> 6
    end
  end

  def desired_play(theirs, outcome) do
    case {theirs, outcome} do
      {:rock, :lose} -> :scissors
      {:rock, :win} -> :paper
      {:paper, :lose} -> :rock
      {:paper, :win} -> :scissors
      {:scissors, :lose} -> :paper
      {:scissors, :win} -> :rock
      {x, :draw} -> x
    end
  end

  def check(input) do
    Enum.reduce(File.stream!(input), 0, fn (line, acc) ->
      [theirs, outcome | _] = String.trim(line) |> String.split(" ") |> Enum.map(fn (choice) ->
        case choice do
          "A" -> :rock
          "B" -> :paper
          "C" -> :scissors
          "X" -> :lose
          "Y" -> :draw
          "Z" -> :win
        end
      end)

      acc + outcome_score(outcome) + Option.score(desired_play(theirs, outcome))
    end)
  end
end


IO.puts("Part 1: #{RPSPart1.check("input.txt")}")
IO.puts("Part 2: #{RPSPart2.check("input.txt")}")
