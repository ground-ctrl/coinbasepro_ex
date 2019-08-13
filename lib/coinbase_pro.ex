defmodule CoinbasePro do
  alias CoinbasePro.HTTPClient

  @moduledoc """
  Elixir wrapper to Coinbase's Pro API.
  
  - All floats, whether they are returned as floats or strings by the API
    are represented as Decimal arbitrary precision numbers.
  - All dates are represented as millisecond UNIX timestamps.

  ## Documentation
   
  https://docs.pro.coinbase.com/
  """

  
  # --------------------------------------
  # PRIVATE
  # Endpoints to manage accounts & orders.
  # --------------------------------------


  @doc """
  Get the list of trading accounts.

  ## Returns

  A list of structs with the following fields
    - id: account id
    - curency: currency of the account
    - balance: funds in the account (Decimal)
    - available: funds available to withdraw or trade (Decimal)
    - hold: funds on hold, not available to use (Decimal)
    - profile_id: user id
  """

  def accounts() do
    api_key = Application.get_env(:coinbasepro, :api_key)
    api_secret = Application.get_env(:coinbasepro, :api_secret)
    api_passphrase = Application.get_env(:coinbasepro, :api_passphrase)

    case HTTPClient.get("/accounts", api_key, api_secret, api_passphrase) do
      {:ok, accounts} -> {:ok, Enum.map(accounts, fn x -> CoinbasePro.Account.new(x) end)}
      err -> err
    end
  end


  # -----------------------------------------------------
  # MARKET DATA
  # Unauthenticated endpoints for retrieving market data.
  # -----------------------------------------------------

  @doc """
  Get a list of available currency pairs for trading.

  ## Returns

  A list of structs with the following fields
    - id: pair id
    - base_currency: the currency being bought
    - quote_currency: the currency used to buy
    - base_min_size: minimum order size (Decimal)
    - base_max_size: maximum order size (Decimal)
    - quote_increment: increment of the order price (Decimal)

  The order price must be a multiple of this increment price.
  """

  def products() do
    case HTTPClient.get("/products") do
      {:ok, products} -> {:ok, Enum.map(products, fn x -> CoinbasePro.Product.new(x) end)}
      err -> err
    end
  end


  @doc """
  Get a current snapshot of Coinbase Pro's order book.

  The order book  is available at 3 levels:
  - level 1: only best bid and best ask are represented
  - level 2: top 50 bids and asks
  - level 3: full order book

  The aggregated levels return the number of bids/asks at the price level. The
  size field is the sum of the sizes of the orders at that price.

  Consider using websockets if you frequently poll level 3.
  """

  def order_book(product, level) do
    case level do
      1 -> order_book_level1(product)
      2 -> order_book_level2(product)
      3 -> order_book_level3(product)
      _ -> {:error, {:argument_error, "level can only be one of {1, 2, 3}"}}
    end
  end

  def order_book_level1(product) do
    params = %{level: 1}
    case HTTPClient.get("/products/#{product}/book", params)  do
      {:ok, book} -> {:ok, CoinbasePro.Book.new_aggregated(book)}
      err -> err
    end
  end

  def order_book_level2(product) do
    params = %{level: 2}
    case HTTPClient.get("/products/#{product}/book", params)  do
      {:ok, book} -> {:ok, CoinbasePro.Book.new_aggregated(book)}
      err -> err
    end
  end

  def order_book_level3(product) do
    params = %{level: 3}
    case HTTPClient.get("/products/#{product}/book", params)  do
      {:ok, book} -> {:ok, CoinbasePro.Book.new(book)}
      err -> err
    end
  end

  @doc """
  Get the latest trade for a product.

  ## Parameter
   
  - product: one of the pair ids returned by products()

  ## Returns

  A list of tuples with the following fields:
  - time: time of the trade in unix timestamp (milliseconds)
  - trade_id: unique id of the trade
  - price: the price at which the transaction occured
  - size: the number of units that were exchanged
  - side: the maker order side "buy" or "sell"
  """

  def trades(product) do
    case HTTPClient.get('/products/#{product}/trades') do
      {:ok, trades} -> {:ok, Enum.map(trades, fn x -> CoinbasePro.Trade.new(x) end)}
      err -> err
    end
  end

  @doc """
  Get historic rates of a product.

  ## Parameters
  
  - product: one of the pair ids returned by products()
  - start: start time in unix timestamp (seconds)
  - end: start time in unix timestamp (seconds)
  - granularity: desired timeslice in seconds 

  `granularity` must be one of {60, 300, 900, 3600, 21600, 86400} or the
  request will be rejected. We pre-handle the rejection.

  If the combination of start/end time and granularity will result in more that
  300 candles the request will be rejected. We pre-handle the rejection.

  If either `start_ts` or `end_ts` are not provided, the API will return the time range
  ending now (with the provided granularity).
  
  ## Returns
  
  A list tuples with the following fiels:
  - time: opening time of the timeslice in unix timestamp (milliseconds)
  - low: lowest quote observed in the timeslice
  - high: highest quote observed in the timeslice
  - open: quote of the first transaction in the timeslice
  - close: quote of the last transaction in the timeslice
  - volume: volume traded in the timeslice
  """

  def candles(product, start_ts, end_ts, granularity)
  when start_ts > end_ts do
    {:error, {:input_error, "the end timestamp you specified is earlier than the start timestamp"}}
  end


  def candles(product, start_ts, end_ts, granularity)
  when (end_ts - start_ts) / granularity > 300 do
    {:error, {:input_error, "the API cannot return more than 300 results: reduce interval or granularity"}}
  end


  def candles(product, start_ts, end_ts, granularity) do
    case Enum.member?([60, 300, 900, 3600, 21600, 86400], granularity) do 
      false -> {:error, {:input_error, "granularity must be one of {60, 300, 900, 3600, 21600, 86400}"}}
      true -> get_candles(product, start_ts, end_ts, granularity)
    end
  end

  
  def get_candles(product, start_ts, end_ts, granularity) do
    start_date = start_ts 
                 |> DateTime.from_unix!()
                 |> DateTime.to_iso8601()
    end_date = end_ts 
               |> DateTime.from_unix!()
               |> DateTime.to_iso8601()

    params = %{
      start: start_date,
      end: end_date,
      granularity: granularity
    }
    case HTTPClient.get('/products/#{product}/candles', params) do
      {:ok, candles} -> {:ok, Enum.map(candles, fn x -> CoinbasePro.Candle.new(x) end)}
      err -> err
    end
  end


  @doc """
  Get the list of known currencies know by Coinbase.
  All known currencies are not necessarily available for trading. See `products`
  for the list of available trading pairs.

  ## Returns

  A list of tuples with the following fields:
  - symbol: currency symbol
  - name: currency name
  - min_size: the minimum amount recognized by Coinbase (Decimal)
  """

  def currencies() do
    case HTTPClient.get('/currencies') do
      {:ok, currencies} -> {:ok, Enum.map(currencies, fn x -> CoinbasePro.Currency.new(x) end)}
      err -> err
    end
  end

  @doc """
  Get the API server time.

  The API returns both a datetime and epoch representation. Since the informations
  are redundant, and the datetime representation is arguably more error-prone we
  only return the epoch time in milliseconds.
  """
  
  def time() do
    case HTTPClient.get('/time') do
      {:ok, time} -> {:ok, CoinbasePro.Time.new(time)}
      err -> err
    end
  end
end
