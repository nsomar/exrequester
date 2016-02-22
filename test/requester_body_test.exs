
defmodule EXRequester.BodyTests do
  use ExUnit.Case

  test "it return error if header keys are missing" do

    defmodule TestAPI5 do
      use EXRequester
      @get "user/{id}"
      defreq get_status(id: id, body: body)
    end

    TestAPI5.client("https://httpbin.org")
    |> TestAPI5.get_status(id: 1, body: "hello")
    assert_received {:request, [get: "https://httpbin.org/user/1", headers: [], body: "hello"]}

    TestAPI5.client("https://httpbin.org")
    |> TestAPI5.get_status(id: 1, body: "hello")
    assert_received {:request, [get: "https://httpbin.org/user/1", headers: [], body: "hello"]}
  end
end
