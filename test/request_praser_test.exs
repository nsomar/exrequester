
defmodule EXRequester.RequestParserTest do
  use ExUnit.Case

  test "it parses a response and decode it if decoder is passed" do
    req =
    %EXRequester.Request{}
    |> EXRequester.Request.add_decoder(fn x -> x.body <> "-123" end)

    parsed =
    EXRequester.ResponseParser.parse_response(%{body: "body"}, req)

    assert parsed == "body-123"
  end

  test "it parses a response and decode it if body_block is passed" do
    body_block = quote do
      var!(response).body <> "-123"
    end

    req =
    %EXRequester.Request{}
    |> EXRequester.Request.add_body_block(body_block)

    parsed =
    EXRequester.ResponseParser.parse_response(%{body: "body"}, req)

    assert parsed == "body-123"
  end

  test "it return the response if nothing was attached" do
    parsed =
    EXRequester.ResponseParser.parse_response(%{body: "body"}, %EXRequester.Request{})

    assert parsed == %{body: "body"}
  end
end
