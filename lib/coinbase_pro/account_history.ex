defmodule CoinbasePro.Account.History do

  @moduledoc """
  An account event as represented by Coinbase Pro's API.
  According to the documentation, events are sent in a payload of the form:

  [
      {
          "id": "100",
          "created_at": "2014-11-07T08:19:27.028459Z",
          "amount": "0.001",
          "balance": "239.669",
          "type": "fee",
          "details": {
              "order_id": "d50ec984-77a8-460a-b958-66f114b0de9b",
              "trade_id": "74",
              "product_id": "BTC-USD"
          }
      }
  ]

  The type can only be one of: transfer, match, fee, rebate, conversion. We represent
  the types as atoms.
  """
  
  defstruct [
    :id,
    :created_at,
    :amount,
    :balance,
    :type,
    :details
  ]

  def new(payload) do
    %CoinbasePro.Account.History{
      id: payload["id"] |> String.to_integer(),
      created_at: payload["created_at"] |> convert_datetime(),
      amount: payload["amount"] |> Decimal.new(),
      balance: payload["balance"] |> Decimal.new(),
      type: payload["type"] |> String.to_atom(),
      details: payload["details"] |> CoinbasePro.Account.HistoryDetail.new()
    }
  end

  def convert_datetime(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, time, _} -> DateTime.to_unix(time, :millisecond)
      err -> err
    end
  end

end


defmodule CoinbasePro.Account.HistoryDetail do

  defstruct [
    :order_id,
    :trade_id,
    :product_id
  ]

  def new(payload) do
    %CoinbasePro.Account.HistoryDetail{
      order_id: payload["order_id"],
      trade_id: payload["trade_id"] |> String.to_integer(),
      product_id: payload["product_id"]
    }
  end

end
