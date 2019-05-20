defmodule Bench do
  inputs = %{
    "small list" => Enum.to_list(1..100),
    "medium list" => Enum.to_list(1..10_000),
    "large list" => Enum.to_list(1..500_000)
  }

  Benchee.run(
    %{
      "Concat: ++" => fn list -> list ++ list end,
      "Concat: Enum.concat" => fn list -> Enum.concat(list, list) end,
      "Concat: Reverse and Cons" => fn list ->
        cons = fn enum_one, enum_two ->
          enum_one
          |> Enum.reverse()
          |> Enum.reduce(enum_two, fn elem, acc ->
            [elem | acc]
          end)
        end

        cons.(list, list)
      end
    },
    inputs: inputs
  )
end
