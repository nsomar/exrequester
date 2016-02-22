
defmodule EXRequester.Response do
  defstruct [:headers, :body, :status_code]

  def parse(%HTTPotion.Response{} = response) do
    %EXRequester.Response{
      headers: Map.get(response, :headers),
      body: Map.get(response, :body),
      status_code: Map.get(response, :status_code)
    }
  end
end
