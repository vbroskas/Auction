defmodule AuctionWeb.GlobalHelpers do
  def integer_to_currency(cents) do
    # dollars_and_cents =
    #   cents
    #   |> Decimal.div(100)
    #   |> Decimal.round(2)

    "$#{cents}"
  end

  def format_time(datetime) do
    datetime
    |> DateTime.from_naive("Etc/UTC")
  end

  def check_ends_at(ends_at) do
    case DateTime.compare(ends_at, DateTime.utc_now()) do
      result when result in [:lt, :eq] ->
        true

      _ ->
        false
    end
  end
end
