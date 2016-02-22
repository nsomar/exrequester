
defmodule EXRequest.ParamsChecker do

  def check_definition_params(function_name, function_params, url, header_keys) do
    function_params = function_params -- [:body]
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

  def check_invocation_params(function_name, function_params, url, header_keys) do
    function_params = function_params -- [:body]
    case check_params(url, header_keys, function_params) do
      {:error, error} ->
        invoked_func = propsed_method_invocation(func_name: function_name, params: function_params)
        correct_func = propsed_method_invocation(func_name: function_name, url: url, header_keys: header_keys)
        {:error, "You are trying to call the wrong function" <>
        "\n#{invoked_func}" <>
        "\nplease instead call:\n#{correct_func}"
        }

      :ok -> :ok
    end
  end

  def check_params(url, header_params, params) do
    params = params || []

    keys_passed = params |> Enum.map(&to_string/1)
    header_params = header_params |> Enum.map(&to_string/1)

    required_params = url_params(url) ++ header_params

    [missing: required_params -- keys_passed,
      extra: keys_passed -- required_params]
      |> adjust_params
  end

  def propsed_method_definition(func_name: func_name, url: url) do
    propsed_method_definition(func_name: func_name, params: url_params(url))
  end

  def propsed_method_definition(func_name: func_name, url: url, header_keys: header_keys) do
    propsed_method_definition(func_name: func_name, params: url_params(url) ++ header_keys)
  end

  def propsed_method_definition(func_name: func_name, params: params) do
    "defreq #{func_name}(#{proposed_params(for_params: params)})"
  end

  def propsed_method_invocation(func_name: func_name, url: url) do
    propsed_method_invocation(func_name: func_name, params: url_params(url))
  end

  def propsed_method_invocation(func_name: func_name, url: url, header_keys: header_keys) do
    propsed_method_invocation(func_name: func_name, params: url_params(url) ++ header_keys)
  end

  def propsed_method_invocation(func_name: func_name, params: params) do
    "#{func_name}(#{proposed_params(for_params: params)})"
  end

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

  def url_params(url) do
    Regex.scan(~r/{.*}/U, url)
    |> Enum.map(fn ([i]) -> String.slice(i, 1..-2) end)
  end

  defp proposed_params(for_params: url_params) do
    Enum.reduce(url_params, "", fn param, acc-> acc <> "#{param}: #{param}, " end)
    |> String.slice(0..-3)
  end

  defp adjust_params(missing: [], extra: []), do: :ok
  defp adjust_params(params), do: {:error, params}

end
