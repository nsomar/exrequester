
defmodule EXRequester.Response do
  @moduledoc """
  Structure that holds a response
  """

  defstruct [:headers, :body, :status_code]

  @doc """
  Return a parsed `EXRequester.Response`

  Parameters:

  * `response` - `HTTPotion.Response` response
  """
  def parse(%HTTPotion.Response{} = response) do
    %EXRequester.Response{
      headers: Map.get(response, :headers),
      body: Map.get(response, :body),
      status_code: Map.get(response, :status_code)
    }
  end

end
