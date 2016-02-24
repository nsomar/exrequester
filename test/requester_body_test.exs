
defmodule EXRequester.BodyTests do
  use ExUnit.Case

  test "it return error if header keys are missing" do

    defmodule TestAPI5 do
      use EXRequester
      @get "user/{id}"
      defreq get_status
    end

    TestAPI5.client("https://httpbin.org")
    |> TestAPI5.get_status(id: 1, body: "hello")
    assert_received {:request, [get: "https://httpbin.org/user/1", headers: [], body: "hello"]}

    TestAPI5.client("https://httpbin.org")
    |> TestAPI5.get_status(id: 1, body: "hello")
    assert_received {:request, [get: "https://httpbin.org/user/1", headers: [], body: "hello"]}
  end

  test "it handles map and list bodies" do

    defmodule TestAPI6 do
      use EXRequester
      @get "user/{id}"
      defreq get_status
    end

    TestAPI6.client("https://httpbin.org")
    |> TestAPI6.get_status(id: 1, body: ["1", "2"])
    assert_received {:request, [get: "https://httpbin.org/user/1", headers: [], body: "[\"1\",\"2\"]"]}

    TestAPI6.client("https://httpbin.org")
    |> TestAPI6.get_status(id: 1, body: "hello")
    assert_received {:request, [get: "https://httpbin.org/user/1", headers: [], body: "hello"]}

    TestAPI6.client("https://httpbin.org")
    |> TestAPI6.get_status(id: 1, body: %{key1: "value1", key2: "value2"})
    assert_received {:request, [get: "https://httpbin.org/user/1", headers: [], body: "{\"key2\":\"value2\",\"key1\":\"value1\"}"]}
  end
end
