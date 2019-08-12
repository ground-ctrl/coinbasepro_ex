defmodule CoinbasePro.Candle do

  @moduledoc """
  Get historic rates for a product.
  According to the official API, a candle is represented as follows:

  [
      [ time, low, high, open, close, volume ],
      [ 1415398768, 0.32, 4.2, 0.35, 4.2, 12.3 ],
      ...
  ]
  """

  defstruct [
    :time,
    :low,
    :high,
    :open,
    :close,
    :volume
  ]

  def new(payload) do
    %CoinbasePro.Candle{
      time: Enum.at(payload,0) * 1000, 
      low: Enum.at(payload, 1) |> Decimal.from_float(),
      high: Enum.at(payload, 2) |> Decimal.from_float(),
      open: Enum.at(payload, 3) |> Decimal.from_float(),
      close: Enum.at(payload, 4) |> Decimal.from_float(),
      volume: Enum.at(payload, 5) |> Decimal.from_float(),
    }
  end

end
