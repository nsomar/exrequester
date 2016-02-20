
defmodule Requester.Performer.HTTPotion do
  @behaviour Requester.Performer
  alias Requester.Request
  alias Requester.Response

  @log_request Application.get_env(:requester, :log_requests, false)

  def do_request(request, params) do
    if @log_request, do: Requester.Logger.log_request(request, params)

    HTTPotion.start()

    response = HTTPotion.request(
      request.method,
      Request.prepared_url(request, params),
      headers: Request.prepared_headers(request, params),
      body: Map.get(request, :body) || ""
    )
    |> Response.parse

    if @log_request, do: Requester.Logger.log_response(response)

    response
  end

end
