defmodule CoinbasePro do
  alias CoinbasePro.HTTPClient

  @moduledoc """
  Elixir wrapper to Coinbase's Pro API.

  ## Documentation
   
  https://docs.pro.coinbase.com/
  """

  @doc """
  Get the list of trading accounts.

  ## Returns

  A list of structs with the following fields
    - id: account id
    - curency: currency of the account
    - balance: funds in the account
    - available: funds available to withdraw or trade
    - hold: funds on hold, not available to use.
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

  @doc """
  Get a list of available currency pairs for trading.

  ## Returns

  A list of structs with the following fields
    - id: pair id
    - base_currency: the currency being bought
    - quote_currency: the currency used to buy
    - base_min_size: minimum order size
    - base_max_size: maximum order size
    - quote_increment: increment of the order price

  The order price must be a multiple of this increment price.
  """

  def products() do
    case HTTPClient.get("/products") do
      {:ok, products} -> {:ok, Enum.map(products, fn x -> CoinbasePro.Product.new(x) end)}
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
  - min_size: the minimum amount recognized by Coinbase
  """

  def currencies() do
    case HTTPClient.get('/currencies') do
      {:ok, currencies} -> {:ok, Enum.map(currencies, fn x -> CoinbasePro.Currency.new(x) end)}
      err -> err
    end
  end
end
