
defmodule EXRequest.ParamsChecker do
  @moduledoc """
  Checks that the function name and params are correct for the definition and invocation
  """

  @doc """
  Checks that the function defined with the parameters is correctly defined for the URL and Header keys

  Parameters:

  * `function_name` - The function name used
  * `function_params` - The function parameters used in definition
  * `url` - The url used to define the function
  * `header_keys` - The headers used to define the function
  """
  def check_definition_params(function_name, function_params, url, header_keys) do
    function_params = function_params -- [:body, :decoder]
    case check_params(url, header_keys, function_params) do
      {:error, error} ->
        defined_func = propsed_method_definition(func_name: function_name, params: function_params)
        correct_func = propsed_method_definition(func_name: function_name, url: url, header_keys: header_keys)

        {:error, "Function definition and url path are not matching:\n" <>
        "URL: #{url}\n" <>
        "Function: #{defined_func}\n" <>
        "Errors:\n" <>
        (definition_param_error_report(error) |> elem(1)) <>
        "\n\nCorrect definition: #{correct_func}"}

      :ok -> :ok
    end
  end

  @doc """
  Checks that the function invocation with the parameters is correctly defined for the URL and Header keys

  Parameters:

  * `function_name` - The function name used
  * `function_params` - The function parameters used in invocation
  * `url` - The url used to invoke the function
  * `header_keys` - The headers used to invoke the function
  """
  def check_invocation_params(function_name, function_params, url, header_keys) do
    function_params = function_params -- [:body, :decoder]
    case check_params(url, header_keys, function_params) do
      {:error, _} ->
        invoked_func = propsed_method_invocation(func_name: function_name, params: function_params)
        correct_func = propsed_method_invocation(func_name: function_name, url: url, header_keys: header_keys)
        {:error, "You are trying to call the wrong function" <>
        "\n#{invoked_func}" <>
        "\nplease instead call:\n#{correct_func}"
        }

      :ok -> :ok
    end
  end

  @doc """
  Checks that the url, header_keys and function parameters match

  Parameters:

  * `url` - The url used to invoke the function
  * `header_params` - The headers used to invoke the function
  * `params` - The function parameters used in invocation
  """
  def check_params(url, header_params, params) do
    params = params || []

    keys_passed = params |> Enum.map(&to_string/1)
    header_params = header_params
    |> filter_header_keys
    |> Enum.map(&to_string/1)

    required_params = url_params(url) ++ header_params

    [missing: required_params -- keys_passed,
      extra: keys_passed -- required_params]
      |> adjust_params
  end

  @doc """
  Get the proposed method definition

  Parameters:

  * `func_name` - The function name used
  * `url` - The url used to define the function
  """
  def propsed_method_definition(func_name: func_name, url: url) do
    propsed_method_definition(func_name: func_name, params: url_params(url))
  end

  @doc """
  Get the proposed method definition

  Parameters:

  * `func_name` - The function name used
  * `url` - The url used to define the function
  * `header_keys` - The header keys used to define the function
  """
  def propsed_method_definition(func_name: func_name, url: url, header_keys: header_keys) do
    header_keys = header_keys |> filter_header_keys
    propsed_method_definition(func_name: func_name, params: url_params(url) ++ header_keys)
  end

  @doc """
  Get the proposed method definition

  Parameters:

  * `func_name` - The function name used
  * `params` - The parameters used in the function
  """
  def propsed_method_definition(func_name: func_name, params: params) do
    "defreq #{func_name}(#{proposed_params(for_params: params)})"
  end

  @doc """
  Get the proposed method invocation

  Parameters:

  * `func_name` - The function name used
  * `url` - The url used to invoke the function
  """
  def propsed_method_invocation(func_name: func_name, url: url) do
    propsed_method_invocation(func_name: func_name, params: url_params(url))
  end

  @doc """
  Get the proposed method definition

  Parameters:

  * `func_name` - The function name used
  * `url` - The url used to invoke the function
  * `header_keys` - The header keys used to invoke the function
  """
  def propsed_method_invocation(func_name: func_name, url: url, header_keys: header_keys) do
    header_keys = header_keys |> filter_header_keys
    propsed_method_invocation(func_name: func_name, params: url_params(url) ++ header_keys)
  end

  @doc """
  Get the proposed method definition

  Parameters:

  * `func_name` - The function name used
  * `params` - The parameters used in the function
  """
  def propsed_method_invocation(func_name: func_name, params: params) do
    "#{func_name}(#{proposed_params(for_params: params)})"
  end

  @doc """
  Get an error string for missing and extra params

  Parameters:

  * `missing` - The missing parameters in the definition
  * `extra` - The extra parameters in the definition
  """
  def definition_param_error_report(missing: [], extra: []), do: :ok

  def definition_param_error_report(missing: missing_params, extra: extra_params) do
    errors = []

    if missing_params != [] do
      errors = errors ++ ["- Parameters [#{Enum.join(missing_params, ", ")}] are missing from function definition"]
    end

    if extra_params != [] do
      errors = errors ++ ["- Parameters [#{Enum.join(extra_params, ", ")}] are ignored in the function definition"]
    end

    {:error, errors |> Enum.join("\n")}
  end

  @doc """
  Get url parametrs from a url
  """
  def url_params(url) do
    Regex.scan(~r/{.*}/r, url)
    |> Enum.map(fn ([i]) -> String.slice(i, 1..-2) end)
  end

  defp filter_header_keys(header_keys) do
    header_keys |> Enum.filter(fn item ->
      is_atom(item)
    end)
  end

  defp proposed_params(for_params: url_params) do
    Enum.reduce(url_params, "", fn param, acc-> acc <> "#{param}: #{param}, " end)
    |> String.slice(0..-3)
  end

  defp adjust_params(missing: [], extra: []), do: :ok
  defp adjust_params(params), do: {:error, params}

end
