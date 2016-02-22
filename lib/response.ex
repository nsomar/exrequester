
defmodule EXRequester.Response do
  defstruct [:headers, :body, :code]

  def parse(%HTTPotion.Response{} = response) do
    %EXRequester.Response{
      headers: Map.get(response, :headers),
      body: Map.get(response, :body),
      code: Map.get(response, :status_code)
    }
  end
end
