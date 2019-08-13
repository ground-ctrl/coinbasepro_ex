defmodule CoinbasePro.Book do

  @moduledoc """
  Representation of Coinbase Pro's order book.

  The API returns two different representations:
  - an aggregated version (level 1 & 2) that only returns the best
    bids and asks.
  - the full version that returns all orders in the book.
  """

  defstruct [
    :sequence,
    :asks,
    :bids,
  ]

  def new(payload) do
    %CoinbasePro.Book{
      sequence: payload["sequence"],
      asks: payload["asks"] |> Enum.map(fn x -> CoinbasePro.Order.new(x) end),
      bids: payload["bids"] |> Enum.map(fn x -> CoinbasePro.Order.new(x) end),
    }
  end

  def new_aggregated(payload) do
    %CoinbasePro.Book{
      sequence: payload["sequence"],
      asks: payload["asks"] |> Enum.map(fn x -> CoinbasePro.AggregateOrder.new(x) end),
      bids: payload["bids"] |> Enum.map(fn x -> CoinbasePro.AggregateOrder.new(x) end),
    }
  end

end



defmodule CoinbasePro.Order do

  @moduledoc """
  Representation of a single order in Coinbase Pro's order book.
  """

  defstruct [
    :price,
    :size,
    :order_id
  ]

  def new(payload) do
    %CoinbasePro.Order{
      price: Enum.at(payload, 0) |> Decimal.new(),
      size: Enum.at(payload, 1) |> Decimal.new(),
      order_id: Enum.at(payload, 2)
    }
  end

end



defmodule CoinbasePro.AggregateOrder do
  
  @moduledoc """
  Representation of aggregated orders in Coinbase Pro's order book.
  """

  defstruct [
    :price,
    :size,
    :num_orders
  ]

  def new(payload) do
    %CoinbasePro.AggregateOrder{
      price: Enum.at(payload, 0) |> Decimal.new(),
      size: Enum.at(payload, 1) |> Decimal.new(),
      num_orders: Enum.at(payload, 2)
    }
  end

end
