defmodule CoinbasePro.HTTPClient do

  @endpoint Application.get_env(:coinbasepro, :endpoint)

  def get(url, params \\ %{}, headers \\ []) do
    arguments = URI.encode_query(params) 
    HTTPoison.get("#{@endpoint}#{url}?#{arguments}", headers)
    |> parse_coinbase_response()
  end


  def get(url, api_key, api_secret, api_passphrase) do

    timestamp = DateTime.utc_now() |> DateTime.to_unix(:second) |> Integer.to_string()
    signature = sign_request(timestamp, "GET", url, "", api_secret)

    headers = [
      {"CB-ACCESS-KEY", api_key},
      {"CB-ACCESS-SIGN", signature},
      {"CB-ACCESS-TIMESTAMP", timestamp},
      {"CB-ACCESS-PASSPHRASE", api_passphrase}
    ]
    
    get(url, %{}, headers)

  end

  def sign_request(timestamp, method, url, body, secret) do
    signature_string = timestamp <> method <> url <> body

    signature =
      :crypto.hmac(
        :sha256,
        secret,
        signature_string
      )
      |> Base.encode64()
  end

  #
  # RESPONSE HANDLING
  #
  
  defp parse_coinbase_response({:ok, response}) do
    case response.status_code do
      400 ->
        {:error, :bad_request}

      401 ->
        {:error, :unauthorized}

      429 ->
        {:error, {:rate_limiting, "too many requests"}}

      500 ->
        {:error, {:server_error, "server error: request may or may not have been successful"}}

      200 ->
        response.body
        |> Jason.decode
    end
  end

  defp parse_coinbase_response({:error, err}) do
    {:error, {:http_error, err}}
  end

end
