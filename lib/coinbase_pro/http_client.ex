defmodule CoinbasePro.HTTPClient do

  @endpoint Application.get_env(:coinbasepro, :endpoint)

  def get(url, params \\ %{}, headers \\ []) do
    arguments = URI.encode_query(params) 
    HTTPoison.get("#{@endpoint}#{url}?#{arguments}", headers)
    |> parse_response()
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

  
  def get_paginated(url, params \\ %{}, headers \\ []) do
    arguments = URI.encode_query(params) 
    HTTPoison.get("#{@endpoint}#{url}?#{arguments}", headers)
    |> parse_paginated_response()
  end


  def get_paginated(url, params, credentials) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix(:second) |> Integer.to_string()
    signature = sign_request(timestamp, "GET", url, "", credentials["api_secret"])

    headers = [
      {"CB-ACCESS-KEY", credentials["api_key"]},
      {"CB-ACCESS-SIGN", signature},
      {"CB-ACCESS-TIMESTAMP", timestamp},
      {"CB-ACCESS-PASSPHRASE", credentials["api_passphrase"]}
    ]

    get_paginated(url, params, headers)
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
    
    signature
  end

  #
  # HANDLE SINGLE PAGE RESPONSE
  #
  
  defp parse_response({:ok, response}) do
    case response.status_code do
      400 ->
        {:error, :bad_request}

      401 ->
        {:error, :unauthorized}

      404 ->
        {:error, {:not_found, "resource not found: make sure that the trading pair you are requesting exists"}}

      429 ->
        {:error, {:rate_limiting, "too many requests"}}

      500 ->
        {:error, {:server_error, "server error: request may or may not have been successful"}}

      200 ->
        response.body
        |> Jason.decode
    end
  end

  defp parse_response({:error, err}) do
    {:error, {:http_error, err}}
  end


  #
  # HANDLE PAGINATED RESPONSE
  #
  
  defp parse_paginated_response({:ok, response}) do
    case response.status_code do
      400 ->
        {:error, :bad_request}

      401 ->
        {:error, :unauthorized}

      404 ->
        {:error, {:not_found, "resource not found: make sure that the trading pair you are requesting exists"}}

      429 ->
        {:error, {:rate_limiting, "too many requests"}}

      500 ->
        {:error, {:server_error, "server error: request may or may not have been successful"}}

      200 -> 
        decode_response(response)
    end
  end

  defp decode_response(response) do
    with {:ok, body} <- Jason.decode(response.body),
         {:ok, page_number} <- find_link(response.headers)
    do
      {:ok, body, page_number}
    end
  end
  
  defp find_link(headers) do
    {:ok, Enum.find_value(headers, fn({k, v}) -> k=="cb-after" && v end)}
  end

end
