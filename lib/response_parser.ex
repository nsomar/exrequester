defmodule EXRequester.ResponseParser do
  @moduledoc """
  Parses the response based on the parameters set in EXRequester.Request
  """

  @doc ~S"""
   Parse an EXRequester.Response using parameters provided in the EXRequester.Request passed  
  """
  def parse_response(http_response, %{body_block: body_block})
  when not is_nil(body_block) do
    {response, _} = Code.eval_quoted(body_block, [response: http_response])
    response
  end

  def parse_response(http_response, %{decoder: decoder})
  when not is_nil(decoder) do
    decoder.(http_response)
  end

  def parse_response(http_response, _) do
    http_response
  end

end
