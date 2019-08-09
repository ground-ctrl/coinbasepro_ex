defmodule CoinbasePro do
  alias CoinbasePro.HTTPClient

  @moduledoc """
  Elixir wrapper to Coinbase's Pro API.

  ## Documentation
   
  https://docs.pro.coinbase.com/
  """
  
  def products() do
    case HTTPClient.get('/products') do
      {:ok, products} -> {:ok, Enum.map(products, fn x -> CoinbasePro.Product.new(x) end)}
      err -> err
    end
  end

end
