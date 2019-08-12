defmodule CoinbasePro.Currency do
  @moduledoc """
  Currency know by Coinbase.
  According to the documentation the payload looks like:

  {
    "id": "BTC",
    "name": "Bitcoin",
    "min_size": "0.00000001"
  }
  """

  defstruct [
    :symbol,
    :name,
    :min_size
  ]

  def new(payload) do
    %CoinbasePro.Currency{
      symbol: payload["id"],
      name: payload["name"],
      min_size: payload["min_size"] |> Decimal.new()
    }
  end
end
