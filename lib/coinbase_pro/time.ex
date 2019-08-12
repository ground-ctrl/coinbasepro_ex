defmodule CoinbasePro.Time do

  @moduledoc """
  The time on Coinbase Pro's servers.
  According to the documentation the payload looks like:

  {
    "iso": "2015-01-07T23:47:25.201Z",
    "epoch": 1420674445.201
  }

  We only return the UNIX timestamp in milliseconds.
  """

  def new(payload) do
    payload["epoch"]
    |> Kernel.*(1000)
    |> Kernel.trunc()
  end

end
