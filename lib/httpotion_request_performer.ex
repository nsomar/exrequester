
defmodule EXRequester.Performer.HTTPotion do
  @moduledoc """
  Implements `EXRequester.Performer` behaviour. Performs an HTTP request using HTTPotion
  """

  @behaviour EXRequester.Performer

  alias EXRequester.Request
  alias EXRequester.Response

  @log_request Application.get_env(:exrequester, :log_requests, false)

  def do_request(request, params) do
    if @log_request, do: EXRequester.Logger.log_request(request, params)

    HTTPotion.start()

    response = HTTPotion.request(
      request.method,
      Request.prepared_url(request, params),
      headers: Request.prepared_headers(request, params),
      body: Request.prepared_body(request)
    )
    |> Response.parse

    if @log_request, do: EXRequester.Logger.log_response(response)

    response
  end

end
