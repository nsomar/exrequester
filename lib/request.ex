
defmodule EXRequester.Request do
  @moduledoc """
  Structure that holds a request
  """

  defstruct [:method, :base_url, :path, :headers_template, :body, :query_keys]

  @doc """
  Return a new request

  Parameters:

  * `method` - The http method
  * `path` - The path to request
  """
  def new(method: method, path: path), do: %EXRequester.Request{method: method, path: path}

  @doc """
  Adds a base url to the request

  Parameters:

  * `request` - request to update
  * `base_url` - base url to add
  """
  def add_base_url(request, base_url), do: Map.put(request, :base_url, base_url)

  @doc """
  Adds headers key to the request

  Parameters:

  * `request` - request to update
  * `headers_keys` - header keys to format
  """
  def add_headers_keys(request, headers_keys), do: Map.put(request, :headers_template, headers_keys)

  @doc """
  Adds body to the request

  Parameters:

  * `request` - request to update
  * `body` - body to add
  """
  def add_body(request, body) do
     Map.put(request, :body, body)
  end

  @doc """
  Adds query keys to the request

  Parameters:

  * `request` - request to update
  * `query_keys` - query keys to add
  """
  def add_query_keys(request, query_keys), do: Map.put(request, :query_keys, query_keys)

  @doc """
  Return a prepared url

  Parameters:

  * `request` - the request
  * `params` - the url to fill in the format url
  """
  def prepared_url(request, params) do
    full_url =
    params
    |> filter_body
    |> filter_body_decoder
    |> Enum.reduce(request.path, fn ({key, value}, acc) ->
      String.replace(acc, "{#{to_string(key)}}", to_string(value))
    end)
    |> (fn item -> join_parts(request.base_url, item) end).()

    url_query = prepared_query(request, params)

    join_urls(full_url, url_query)
  end

  @doc """
  Return prepared header keyword list

  Parameters:

  * `request` - the request
  * `header_params` - the header parametrs to update with the keys
  """
  def prepared_headers(request, header_params) do
    header_params = header_params |> filter_body
    header_keys = Map.get(request, :headers_template, [])

    Enum.map(header_keys, fn {key, value} ->
      prepare_header_item(template_key: key, template_value: value, header_params: header_params)
    end) || []
  end

  @doc """
  Return a prepared query string

  Parameters:

  * `request` - the request
  * `params` - the parameters to use to create the query string
  """
  def prepared_query(request, params) do
    query_keys = Map.get(request, :query_keys) || []

    params
    |> Enum.filter(fn {key, _} ->
      key in query_keys
    end)
    |> Enum.map(fn {key, value} ->
      "#{key}=#{prepare_query_value(value)}"
    end)
    |> Enum.join("&")
  end

  # Private

  defp join_urls(url, ""), do: url

  defp join_urls(url, query), do: "#{url}?#{query}"

  def prepared_body(request) do
    _prepared_body(Map.get(request, :body)) || ""
  end

  defp _prepared_body(nil), do: nil

  defp _prepared_body(body) when is_tuple(body) do
    body_to_json(Tuple.to_list(body))
  end

  defp _prepared_body(body) when is_map(body) or is_list(body) do
    body_to_json(body)
  end

  defp _prepared_body(body), do: body

  defp body_to_json(body) do
    case Poison.encode(body) do
      {:ok, json} -> json
      _ -> ""
    end
  end

  defp prepare_header_item(template_key: key, template_value: value, header_params: _)
  when is_binary(value) do
    {key, value}
  end

  defp prepare_header_item(template_key: key, template_value: value, header_params: header_params) do
    {key, header_params[value]}
  end

  defp prepare_query_value(value) when is_list(value) do
    Enum.join(value, ",")
  end

  defp prepare_query_value(value), do: value

  defp join_parts(base, path) do
    join_parts(String.slice(base, 0..-2),
    String.slice(base, -1..-1),
    String.slice(path, 0..0),
    String.slice(path, 1..-1))
  end

  defp join_parts(base, "/", "/", path) do
    base <> "/" <> path
  end

  defp join_parts(base, "/", path_start, path) do
    base <> "/" <> path_start <> path
  end

  defp join_parts(base, base_end, "/", path) do
    base <> base_end <> "/" <> path
  end

  defp join_parts(base, base_end, path_start, path) do
    base <> base_end <> "/" <> path_start <> path
  end

  defp filter_body(params) do
    Enum.filter(params, fn {key, _} ->
      key != :body
    end)
  end

  defp filter_body_decoder(params) do
    Enum.filter(params, fn {key, _} ->
      key != :decoder
    end)
  end
end
