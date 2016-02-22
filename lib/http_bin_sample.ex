defmodule HTTPBinSample do
  use EXRequester

  @get "/rvnwnlrv/status/{status}"
  defreq get_status(status: status)

  @query [:sort, :filter]
  @headers [
    Authorization: :auth,
    Key1: :key1,
  ]
  @get "a_url"
  defreq some_request(auth: auth, key1: key1)

  @post "a_url_with_body"
  defreq request_with_body(body: body)

  @query [:sort, :filter]
  @get "response-headers"
  defreq get_resource()
end

defmodule Mix.Tasks.MyTask do
  use Mix.Task
  use EXRequester

  @shortdoc "do stuff"
  def run(_) do

    HTTPBinSample.client("http://requestb.in")
    |> HTTPBinSample.get_status(status: 418)

    HTTPBinSample.client("http://localhost:9090/")
    |> HTTPBinSample.some_request(auth: "password", key1: "The_value")

    HTTPBinSample.client("http://localhost:9090/")
    |> HTTPBinSample.request_with_body(body: "Hello World")

    HTTPBinSample.client("https://httpbin.org")
    |> HTTPBinSample.get_resource(sort: "ascending", filter: ["all", "2"])

    HTTPBinSample.client("http://localhost:9090/")
    |> HTTPBinSample.request_with_body(body: %{key1: "value1", key2: "value2"})
  end

end
