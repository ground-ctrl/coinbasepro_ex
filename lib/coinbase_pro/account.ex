defmodule CoinbasePro.Account do

  @moduledoc """
  Get trading accounts informations.
  According to the official API, an account is represented as:

  {
     "id": "e316cb9a-0808-4fd7-8914-97829c1925de",
     "currency": "USD",
     "balance": "80.2301373066930000",
     "available": "79.2266348066930000",
     "hold": "1.0035025000000000",
     "profile_id": "75da88c5-05bf-4f54-bc85-5c775bd68254"
  }
  """

  defstruct [
    :id,
    :currency,
    :balance,
    :available,
    :hold,
    :profile_id
  ]

  def new(payload) do
    %CoinbasePro.Account{
      id: payload["id"],
      currency: payload["currency"],
      balance: payload["balance"] |> Decimal.new(),
      available: payload["available"] |> Decimal.new(),
      hold: payload["hold"] |> Decimal.new(),
      profile_id: payload["profile_id"],
    }
  end
end
