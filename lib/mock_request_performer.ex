
defmodule EXRequester.Performer.Mock do
  @moduledoc """
  Implements `EXRequester.Performer` behaviour. Mocks an HTTP request by sending message to self
  This class is used in tests
  """

  @behaviour EXRequester.Performer

  alias EXRequester.Request
  def do_request(request, params)  do
    sent = ["#{request.method}": "#{Request.prepared_url(request, params)}"]

    if Map.get(request, :headers_template) do
      sent = sent ++ [headers: Request.prepared_headers(request, params)]
    end

    if Map.get(request, :body) do
      sent = sent ++ [body: Request.prepared_body(request)]
    end

    send self(), {
      :request,
      sent
    }
    %EXRequester.Response{
      status_code: 200,
      body: "123",
      headers: [k1: "v2"]
    }
  end

end
