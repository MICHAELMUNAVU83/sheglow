defmodule SheglowWeb.Format do
  @moduledoc "Shared formatting helpers for templates."

  @doc "Formats an integer/float/Decimal as a comma-separated string. e.g. 30800 → \"30,800\""
  def price(nil), do: "0"
  def price(%Decimal{} = n), do: n |> Decimal.to_float() |> price()
  def price(n) when is_binary(n) do
    case Float.parse(n) do
      {f, _} -> price(f)
      :error -> "0"
    end
  end

  def price(n) do
    n
    |> trunc()
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.join()
  end
end
