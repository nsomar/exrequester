
defmodule EXRequester.Performer do
  @moduledoc """
  Behaviour that defines a request performer
  """

  @doc """
  Performs a request

  * `method` - the http method
  * `client` - The http client
  * `url` - The url to request
  * `params` - params to be filled in the url
  """
  @callback do_request(request :: %EXRequester.Request{}, params :: [atom: String.t]) :: %HTTPotion.Response{}
end
