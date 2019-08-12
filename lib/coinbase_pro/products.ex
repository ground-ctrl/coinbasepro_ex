defmodule CoinbasePro.Product do

  @moduledoc """
  An available currency pairs for trading.
  According to the documentation the payload looks like:

  {
      "id": "BTC-USD",
      "base_currency": "BTC",
      "quote_currency": "USD",
      "base_min_size": "0.001",
      "base_max_size": "10000.00",
      "quote_increment": "0.01"
  }
  """

  defstruct [
    :id,
    :base_currency,
    :quote_currency,
    :base_min_size,
    :base_max_size,
    :quote_increment
  ]

  def new(payload) do
    %CoinbasePro.Product{
      id: payload["id"],
      base_currency: payload["base_currency"],
      quote_currency: payload["quote_currency"],
      base_min_size: payload["base_min_size"] |> Decimal.new(),
      base_max_size: payload["base_max_size"] |> Decimal.new(),
      quote_increment: payload["quote_increment"] |> Decimal.new()
    }
  end
end
