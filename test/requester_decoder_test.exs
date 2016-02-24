
defmodule EXRequester.DEcoderTests do
  use ExUnit.Case

  test "it return error if header keys are missing" do
    defmodule TestAPIA6 do
      use EXRequester

      @put "user/{id}"
      defreq get_status
    end

    res = TestAPIA6.client("https://httpbin.org")
    |> TestAPIA6.get_status(id: 1, decoder: fn response ->
      "before-" <> response.body <> "-after"
    end)

    assert res == "before-123-after"
  end

  test "it return the same response if decoder is not set" do
    defmodule TestAPIA7 do
      use EXRequester

      @put "user/{id}"
      defreq get_status
    end

    res = TestAPIA7.client("https://httpbin.org")
    |> TestAPIA7.get_status(id: 1)

    assert res.body == "123"
  end

end
