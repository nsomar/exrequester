
defmodule EXRequester.HeaderTests do
  use ExUnit.Case

  test "it raise error if calling method with wrong parametrs" do

    defmodule TestAPI6 do
      use EXRequester

      @headers [
        Authorization: :authorization,
        Key1: :key1,
      ]

      @get "user/{id}"
      defreq get_status
    end

    assert_raise(RuntimeError,
    "\n\nYou are trying to call the wrong function:\n  get_status(client, id: id, authorization: authorization)\nPlease instead call:\n  get_status(client, id: id, authorization: authorization, key1: key1)\n",
    fn ->
      TestAPI6.client("https://httpbin.org")
      |> TestAPI6.get_status(id: 1, authorization: 20)
    end)
  end

  test "it does not raise if called correctly" do

    defmodule TestAPI7 do
      use EXRequester

      @headers [
        Authorization: :authorization,
        Key1: :key1,
      ]

      @get "user/{id}"
      defreq get_status
    end

    TestAPI7.client("https://httpbin.org")
    |> TestAPI7.get_status(id: 1, authorization: 20, key1: 2)

    assert_received  {:request, [get: "https://httpbin.org/user/1", headers: [Authorization: 20, Key1: 2]]}
  end

  test "it ignores string headers" do

    defmodule TestAPI8 do
      use EXRequester

      @headers [
        Authorization: :authorization,
        Key1: "The Value Is 123",
      ]

      @get "user/{id}"
      defreq get_status
    end
  end

  test "it sends the textual header as is" do

    defmodule TestAPI9 do
      use EXRequester

      @headers [
        Authorization: :authorization,
        "Key1": "The Value Is 123",
      ]

      @get "user/{id}"
      defreq get_status
    end

    TestAPI9.client("https://httpbin.org")
    |> TestAPI9.get_status(id: 1, authorization: 20)

    assert_received  {:request, [get: "https://httpbin.org/user/1", headers: [Authorization: 20, Key1: "The Value Is 123"]]}
  end

  test """
  it sends headers even if the function has no params
  https://github.com/oarrabi/exrequester/issues/2
  """ do

    defmodule Api do
      use EXRequester
      @headers [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "x-user-token": "a892079d-8028-46ec-8208-225e1a0e3af5",
        "x-user-email": "demo@example.com",
      ]
      @get "/posts"
      defreq get_posts
    end

    Api.client("https://httpbin.org")
    |> Api.get_posts()

    assert_received  {:request, [get: "https://httpbin.org/posts", headers: ["Content-Type": "application/json", Accept: "application/json", "x-user-token": "a892079d-8028-46ec-8208-225e1a0e3af5", "x-user-email": "demo@example.com"]]}
  end

end
