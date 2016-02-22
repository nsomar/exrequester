
defmodule EXRequester.HeaderTests do
  use ExUnit.Case

  test "it return error if header keys are missing" do

    assert_raise(ArgumentError,
    "Function definition and url path are not matching:\nURL: user/{id}\nFunction: defreq get_status(id: id, key1: key1)\nErrors:\n- Parameters [authorization] are missing from function definition\n\nCorrect definition: defreq get_status(id: id, authorization: authorization, key1: key1)",
    fn ->
      defmodule TestAPI5 do
        use EXRequester

        @headers [
          Authorization: :authorization,
          Key1: :key1,
        ]

        @get "user/{id}"
        defreq get_status(id: id, key1: key1)
      end
    end)
  end

  test "it raise error if calling method with wrong parametrs" do

    defmodule TestAPI6 do
      use EXRequester

      @headers [
        Authorization: :authorization,
        Key1: :key1,
      ]

      @get "user/{id}"
      defreq get_status(id: id, authorization: authorization, key1: key1)
    end

    assert_raise(RuntimeError,
    "You are trying to call the wrong function\nget_status(id: id, authorization: authorization)\nplease instead call:\nget_status(id: id, authorization: authorization, key1: key1)",
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
      defreq get_status(id: id, authorization: authorization, key1: key1)
    end

    TestAPI7.client("https://httpbin.org")
    |> TestAPI7.get_status(id: 1, authorization: 20, key1: 2)

    assert_received  {:request, [get: "https://httpbin.org/user/1", headers: [Authorization: 20, Key1: 2]]}
  end

end
