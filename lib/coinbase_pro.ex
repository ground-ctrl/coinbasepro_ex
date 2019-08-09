defmodule CoinbasePro do
  alias CoinbasePro.HTTPClient

  @moduledoc """
  Elixir wrapper to Coinbase's Pro API.

  ## Documentation
   
  https://docs.pro.coinbase.com/
  """

  def accounts() do
    api_key = Application.get_env(:coinbasepro, :api_key)
    api_secret = Application.get_env(:coinbasepro, :api_secret)
    api_passphrase = Application.get_env(:coinbasepro, :api_passphrase)

    case HTTPClient.get("/accounts", api_key, api_secret, api_passphrase) do
      {:ok, accounts} -> {:ok, Enum.map(products, fn x -> CoinbasePro.Account.new(x) end)}
      err -> err
    end
  end
  
  def products() do
    case HTTPClient.get("/products") do
      {:ok, products} -> {:ok, Enum.map(products, fn x -> CoinbasePro.Product.new(x) end)}
      err -> err
    end
  end

end
