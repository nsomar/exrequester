
defmodule Requester.Logger do

  alias Requester.Request
  alias Requester.Response

  def log_request(request, params) do
    [
      "\n--- Performing request ---",
      "Method: #{request.method}",
      "URL: #{Request.prepared_url(request, params)}",
      "Headers: #{get_log_headers(request, params)}",
      "Body: #{get_log_body(Map.get(request, :body))}"
    ]
    |> Enum.join("\n")
    |> IO.puts
  end

  def log_response(response) do
    [
      "\n--- Receiving response ---",
      "Status: #{response.code}",
      "Headers: #{get_log_headers(response.headers)}",
      "Body: #{response.body}"
    ]
    |> Enum.join("\n")
    |> IO.puts
  end

  defp get_log_body(nil), do: "..."
  defp get_log_body(body), do: body

  defp get_log_headers(request, params) do
    Request.prepared_headers(request, params)
    |> get_log_headers
  end

  defp get_log_headers([]), do: "..."

  defp get_log_headers(headers) do
    headers |> Enum.map(fn {key, value} ->
      "\n - " <> to_string(key) <> ": " <> value
    end)
    |> Enum.join("")
  end

end
