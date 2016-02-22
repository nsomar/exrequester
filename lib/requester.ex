
defmodule EXRequester do

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      def client(url) do
        %{url: url}
      end
    end
  end

  defmacro defreq(head) do
    post_defreq(head)
  end

  def post_defreq({function_name, _, [params| _]}) do
    define_functions(function_name, params)
  end

  def post_defreq({function_name, _, _}) do
    define_functions(function_name, nil)
  end

  defp define_functions(function_name, params) do
    params = params || []
    function_params = params && Keyword.keys(params)

    quote bind_quoted: [
      function_name: function_name,
      function_params: function_params] do

      [{request_method, request_path}] = get_request_path_and_method
      headers = get_request_headers
      query = get_request_query

      request = quote do
        EXRequester.Request.new(method: unquote(request_method), path: unquote(request_path))
        |> EXRequester.Request.add_headers_keys(unquote(headers))
        |> EXRequester.Request.add_query_keys(unquote(query))
      end

      proposed_method =
      EXRequest.ParamsChecker.propsed_method_invocation(func_name: function_name, url: request_path)

      res = EXRequest.ParamsChecker.check_definition_params(
      function_name,
      function_params -- query,
      request_path,
      Keyword.values(headers)
      )

      define_function(res, function_params, function_name, proposed_method, request)
      clear_attributes
    end

  end

  defmacro define_function(res, params, function, proposed, request) do
    quote do
      case unquote(res) do

        {:error, error} ->
          raise ArgumentError, error

        :ok ->
          unquote(define_function(params, function, request))
          unquote(define_catch_error_function(params, function, proposed))
          unquote(define_catch_error_for_empty(function, proposed))
      end
    end
  end

  def define_function(nil, function_name, request) do
    request = Macro.escape(request)
    quote bind_quoted: [
      function_name: function_name,
      request: request] do

      def unquote(function_name)(client) do
        request = unquote(request)
        |> EXRequester.Request.add_base_url(client.url)

        check_called_correctly(unquote(function_name), params, request)
        Application.get_env(:exrequester, :request_performer).do_request(request, nil)
      end

    end
  end

  def define_function(_, function_name, request) do
    quote bind_quoted: [function_name:
    function_name,
    request: request] do

      def unquote(function_name)(client, params) do
        request = unquote(request)
        |> EXRequester.Request.add_body(params)
        |> EXRequester.Request.add_base_url(client.url)

        check_called_correctly(unquote(function_name), params, request)
        Application.get_env(:exrequester, :request_performer).do_request(request, params)
      end

    end
  end

  def check_called_correctly(function_name, params, request) do
    params = params || []
    headers_template = request.headers_template || []

    case EXRequest.ParamsChecker.check_invocation_params(
    function_name,
    Keyword.keys(params) -- request.query_keys,
    request.path,
    Keyword.values(headers_template))
    do
      :ok -> :ok
      {:error, error} ->
        raise RuntimeError, error
    end
  end

  def define_catch_error_for_empty(function_name, proposed_function) do
    quote bind_quoted: [
      function_name: function_name,
      proposed_function: proposed_function] do

      def unquote(function_name)() do
        called_function = "#{unquote(function_name)}"
        raise RuntimeError, exception_to_raise(called_function, unquote(proposed_function))
      end

    end
  end

  def define_catch_error_function(nil, function_name, proposed_function) do
    quote bind_quoted: [
      function_name: function_name,
      proposed_function: proposed_function] do

      def unquote(function_name)(client, other) do
        called_function = "#{unquote(function_name)}(client, other...)"
        raise RuntimeError, exception_to_raise(called_function, unquote(proposed_function))
      end

    end
  end

  def define_catch_error_function(_, function_name, proposed_function) do
    quote bind_quoted: [
      function_name: function_name,
      proposed_function: proposed_function] do

      def unquote(function_name)(client) do
        called_function = "#{unquote(function_name)}(client)"
        raise RuntimeError, exception_to_raise(called_function, unquote(proposed_function))
      end

    end
  end

  defmacro get_request_path_and_method do
    quote do
      [:get, :post, :put, :delete]
      |> Enum.map(fn method ->
        {method, Module.get_attribute(__MODULE__, method)}
      end)
      |> Enum.filter(fn {_, item} -> item != nil end)
      |> check_has_http_method
    end
  end

  defmacro get_request_headers do
    quote do
      Module.get_attribute(__MODULE__, :headers) || []
    end
  end

  defmacro get_request_query do
    quote do
      Module.get_attribute(__MODULE__, :query) || []
    end
  end

  def exception_to_raise(called_function, correct_function) do
    "You are trying to call the wrong function" <>
    "\n#{called_function}" <>
    "\nplease instead call:\n#{correct_function}"
  end

  def check_has_http_method([]) do
    raise ArgumentError,
    "Missing http method/url attribute\n" <>
    "Example:\n" <>
    "  @get(\"user/{user_id}/pictures/{picture_id}\")\n" <>
    "  @post(\"user/{user_id}/upload_picture\")"
  end

  def check_has_http_method(arr), do: arr

  def possible_attributes do
    [:get, :post, :put, :delete, :headers, :body]
  end

  defmacro clear_attributes do
    quote do
      Enum.each(possible_attributes, fn attr ->
        Module.delete_attribute(__MODULE__, attr)
      end)
    end
  end

end
