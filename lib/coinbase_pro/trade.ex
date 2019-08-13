defmodule CoinbasePro.Trade do

  @moduledoc """
  A trade as represented by Coinbase Pro's API.
  According to the documentation, trades are sent in a payload of the form:

  [{
      "time": "2014-11-07T22:19:28.578544Z",
      "trade_id": 74,
      "price": "10.00000000",
      "size": "0.01000000",
      "side": "buy"
  }, {
      "time": "2014-11-07T01:08:43.642366Z",
      "trade_id": 73,
      "price": "100.00000000",
      "size": "0.01000000",
      "side": "sell"
  }]
  """

  defstruct [
    :time,
    :trade_id,
    :price,
    :size,
    :side
  ]

  def new(payload) do
    %CoinbasePro.Trade{
      time: payload["time"] |> convert_datetime(),
      trade_id: payload["trade_id"],
      price: payload["price"] |> Decimal.new(),
      size: payload["size"] |> Decimal.new(),
      side: payload["side"],
    }
  end

  def convert_datetime(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, time, _} -> DateTime.to_unix(time, :millisecond)
      err -> err
    end
  end

end
