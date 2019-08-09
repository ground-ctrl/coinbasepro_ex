defmodule CoinbasePro.HTTPClient do

  @endpoint Application.get_env(:coinbasepro, :endpoint)

  def get(url) do
    HTTPoison.get("#{@endpoint}#{url}")
    |> parse_coinbase_response()
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
