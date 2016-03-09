
defmodule EXRequester do
  @moduledoc """
  `EXRequester` requester main class
  """

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      def client(url) do
        %{url: url}
      end
    end
  end

  @doc """
  Define a request function

  Parameters:

  * `head` - the function header AST

  ## Example

  To define an api:

      defmodule SampleAPI do
        use EXRequester

        @headers [
          Authorization: :auth,
          Key1: :key1
        ]
        @get "/path/to/resource/{resource_id}"
        defreq get_resource
      end

  Then to call it:

      SampleAPI.client("http://base_url.com")
      |> SampleAPI.get_resource(resource_id: 123, auth1: "1", key1: "2")

  This will hit
  `http://base_url.com/path/to/resource/123`
  The `Authorization` and `Key1` headers will also be set.

  If you want to decode the response, you can do it in three ways:

  First: At the function definition, by passing an anonymous function, For example;

      defmodule SampleAPI do
        ....
        defreq get_resource(fn response ->
          "Value is " <> response.body
        end)
      end

  When calling `get_resource` the HTTP response of type `EXRequester.Response` will be sent to the passed anonymous function.
  Using this way, you can create a response decoder in place.

  Second: By defining a body to the get_resource function, inside this body, you can use `response` object which will be injected by the macro

      defmodule SampleAPI do
        ....
        defreq get_resource do
          "Value is " <> response.body
        end
      end

  `response` will be set by the macro to the value of the `EXRequester.Response` received.

  Alternatively, you can pass a response decoder when calling the method pass a decoder as a parameter when calling `get_resource` For example:

        SampleAPI.client("http://base_url.com")
        |> SampleAPI.get_resource(resource_id: 123, auth1: "1", key1: "2", decoder: fn response ->
          "Value is " <> response.body
        end)


  The anonymous function passed to decoder will receive an `EXRequester.Response`. This function can parse the response and return a parsed response. The parsed response will be finally returned.

  Note: The decoder passed when calling the method overwrites the decoder declated when defining the method in the module.

  The example above returns `"Value is Content of body"`
  """
  defmacro defreq(head) do
    post_defreq(head, nil)
  end

  defmacro defreq(head, do: body) do
    post_defreq(head, body)
  end

  def post_defreq(head, body \\ nil)

  def post_defreq({function_name, _, [decoder]}, body) do
    define_functions(function_name, decoder, body)
  end

  def post_defreq({function_name, _, _}, body) do
    define_functions(function_name, nil, body)
  end

  defp define_functions(function_name, decoder, body) do
    quote bind_quoted: [
      function_name: function_name,
      body: Macro.escape(body),
      decoder: Macro.escape(decoder)
      ] do

      [{request_method, request_path}] = get_request_path_and_method
      headers = get_request_headers
      query = get_request_query

      body_e = Macro.escape(body)
      request = quote do
        EXRequester.Request.new(method: unquote(request_method), path: unquote(request_path))
        |> EXRequester.Request.add_headers_keys(unquote(headers))
        |> EXRequester.Request.add_query_keys(unquote(query))
        |> EXRequester.Request.add_decoder(unquote(decoder))
        |> EXRequester.Request.add_body_block(unquote(body_e))
      end

      proposed_method =
      EXRequest.ParamsChecker.propsed_method_invocation(func_name: function_name, url: request_path)

      has_params = EXRequest.ParamsChecker.check_has_params(url: request_path,
      headers: headers, query: query)

      define_function(has_params, function_name, proposed_method, request)
      clear_attributes
    end
  end

  @doc """
  Define the function to call

  Parameters:

  * `has_params` - the function has any parameter
  * `function` - the function name to define
  * `proposed` - the proposesd function definition to use
  * `request` - `EXRequester.request` to use
  """
  defmacro define_function(has_params, function, proposed, request) do
    quote do
      unquote(define_function(name: function, request: request, has_params: has_params))
      unquote(define_catch_error_function(name: function, proposed: proposed, has_params: has_params))
      unquote(define_catch_error_for_empty(name: function, proposed: proposed))
    end
  end

  @doc """
  Define the function to call

  Parameters:

  * `function_name` - the function name to define
  * `request` - `EXRequester.request` to use
  * `has_params` - the function has any parameter
  """
  def define_function(name: function_name, request: request, has_params: has_params) do
    quote bind_quoted: [has_params: has_params], unquote: true do
      if has_params do
        unquote(define_function_with_params(name: function_name, request: request, has_params: true))
      else
        unquote(define_function_with_params(name: function_name, request: request, has_params: false))
      end
    end
  end

  defp define_function_with_params(name: function_name, request: request, has_params: true) do
    quote bind_quoted:
    [function_name: function_name,
    request: request] do

      def unquote(function_name)(client, params) do
        request = unquote(request)
        |> EXRequester.Request.add_body(params[:body])
        |> EXRequester.Request.add_base_url(client.url)
        |> EXRequester.Request.add_decoder(params[:decoder])

        perform_request_and_parse(unquote(function_name), params, request)
      end
    end
  end

  defp define_function_with_params(name: function_name, request: request, has_params: false) do
    quote bind_quoted:
    [function_name: function_name,
    request: request] do
      def unquote(function_name)(client) do
        request = unquote(request)
        |> EXRequester.Request.add_base_url(client.url)

        perform_request_and_parse(unquote(function_name), nil, request)
      end
    end
  end

  def perform_request_and_parse(function_name, params, request) do
    check_called_correctly(function_name, params, request)

    request_performer.do_request(request, params)
    |> EXRequester.ResponseParser.parse_response(request)
  end

  defp request_performer do
    Application.get_env(:exrequester, :request_performer, EXRequester.Performer.HTTPotion)
  end

  @doc """
  Check that the function was called correctly

  Parameters:

  * `function_name` - the function name to define
  * `params` - the function parameters used
  * `request` - `EXRequester.request` to use
  """
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

  @doc """
  Define a catch error function

  Parameters:

  * `function_name` - the function name to define
  * `proposed_function` - the proposed function to define
  """
  def define_catch_error_for_empty(name: function_name, proposed: proposed_function) do
    quote bind_quoted: [
      function_name: function_name,
      proposed_function: proposed_function] do

      def unquote(function_name)() do
        called_function = "#{unquote(function_name)}"
        raise RuntimeError, exception_to_raise(called_function, unquote(proposed_function))
      end

    end
  end

  @doc """
  Define a catch error function

  Parameters:


  * `function_name` - the function name to define
  * `proposed_function` - the proposed function to define
  * `has_params` - the function has any parameter
  """
  def define_catch_error_function(name: function_name, proposed: proposed_function, has_params: has_params) do
    quote bind_quoted: [has_params: has_params], unquote: true do

        if has_params do
          unquote(define_catch_error_function_with_params(name: function_name, proposed: proposed_function, has_params: true))
        else
          unquote(define_catch_error_function_with_params(name: function_name, proposed: proposed_function, has_params: false))
        end
    end
  end

  @doc """
  Define a catch error function

  Parameters:

  * `function_name` - the function name to define
  * `proposed_function` - the proposed function to define
  * `has_params` - the function has any parameter
  """
  defp define_catch_error_function_with_params(name: function_name, proposed: proposed_function, has_params: false) do
    quote bind_quoted: [
      function_name: function_name,
      proposed_function: proposed_function] do

      def unquote(function_name)(client, other) do
        called_function = "#{unquote(function_name)}(client, other...)"
        raise RuntimeError, exception_to_raise(called_function, unquote(proposed_function))
      end

    end
  end

  defp define_catch_error_function_with_params(name: function_name, proposed: proposed_function, has_params: true) do
    quote bind_quoted: [
      function_name: function_name,
      proposed_function: proposed_function] do

      def unquote(function_name)(client) do
        called_function = "#{unquote(function_name)}(client)"
        raise RuntimeError, exception_to_raise(called_function, unquote(proposed_function))
      end

    end
  end

  @doc """
  Read the module attribute that define the request HTTP method and path defined
  """
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

  @doc """
  Read the module attribute that defines the headers
  """
  defmacro get_request_headers do
    quote do
      Module.get_attribute(__MODULE__, :headers) || []
    end
  end

  @doc """
  Read the module attribute that the query keys
  """
  defmacro get_request_query do
    quote do
      Module.get_attribute(__MODULE__, :query) || []
    end
  end

  @doc """
  Exception to raise if the function was called incorrectly

  Parameters:

  * `called_function` - the function called
  * `correct_function` - the correct function to call
  """
  def exception_to_raise(called_function, correct_function) do
    "You are trying to call the wrong function" <>
    "\n#{called_function}" <>
    "\nplease instead call:\n#{correct_function}"
  end

  @doc """
  Ensure that the http method was defined
  """
  def check_has_http_method([]) do
    raise ArgumentError,
    "Missing http method/url attribute\n" <>
    "Example:\n" <>
    "  @get(\"user/{user_id}/pictures/{picture_id}\")\n" <>
    "  @post(\"user/{user_id}/upload_picture\")"
  end

  def check_has_http_method(arr), do: arr

  @doc """
  Return all the possible attributes to define in the method
  """
  def possible_attributes do
    [:get, :post, :put, :delete, :headers, :body]
  end

  @doc """
  Clear the module attributes after defining the functions
  """
  defmacro clear_attributes do
    quote do
      Enum.each(possible_attributes, fn attr ->
        Module.delete_attribute(__MODULE__, attr)
      end)
    end
  end

end
