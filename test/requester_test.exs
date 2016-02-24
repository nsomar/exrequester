
defmodule EXRequester.Tests do
  use ExUnit.Case

  test "it compiles when arguments in function and url matches" do

    defmodule TestAPI3 do
      use EXRequester

      @get "user/{id}"
      defreq get_status
    end
  end

  test "it throws error if wrong method is called" do

    defmodule TestAPI4 do
      use EXRequester

      @get "user/{id}"
      defreq get_status
    end

    assert_raise(RuntimeError,
    "You are trying to call the wrong function\nget_status(client)\nplease instead call:\nget_status(client, id: id)",
    fn ->
      TestAPI4.client("https://httpbin.org/")
      |> TestAPI4.get_status
    end)

    assert_raise(RuntimeError,
    "You are trying to call the wrong function\nget_status(client, id: id, name: name)\nplease instead call:\nget_status(client, id: id)",
    fn ->
      TestAPI4.client("https://httpbin.org/")
      |> TestAPI4.get_status(id: 1, name: 2)
    end)
  end

  test "it throws error if get/post/put/delete are not present" do

    assert_raise(ArgumentError,
     "Missing http method/url attribute\nExample:\n  @get(\"user/{user_id}/pictures/{picture_id}\")\n  @post(\"user/{user_id}/upload_picture\")",
     fn ->
      defmodule TestAPI4a do
        use EXRequester
        defreq get_status
      end
    end)

  end

end
