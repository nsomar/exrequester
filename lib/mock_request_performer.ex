defmodule EXRequester.Performer.Mock do
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
  end

end
