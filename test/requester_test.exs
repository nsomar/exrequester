
defmodule EXRequester.Tests do
  use ExUnit.Case

  test "it does not compile when missing arguments in function" do

    assert_raise(ArgumentError,
    "Function definition and url path are not matching:\nURL: user/{id}\nFunction: defreq get_status()\nErrors:\n- Parameters [id] are missing from function definition\n\nCorrect definition: defreq get_status(id: id)",
    fn ->
      defmodule TestAPI1 do
        use EXRequester

        @get "user/{id}"
        defreq get_status
      end
    end)
  end

  test "it does not compile when extra arguments in function" do

    assert_raise(ArgumentError,
    "Function definition and url path are not matching:\nURL: user/{id}\nFunction: defreq get_status(id: id, name: name)\nErrors:\n- Parameters [name] are ignored in the function definition\n\nCorrect definition: defreq get_status(id: id)",
    fn ->
      defmodule TestAPI2 do
        use EXRequester

        @get "user/{id}"
        defreq get_status(id: id, name: name)
      end
    end)
  end

  test "it compiles when arguments in function and url matches" do

    defmodule TestAPI3 do
      use EXRequester

      @get "user/{id}"
      defreq get_status(id: id)
    end
  end

  test "it throws error if wrong method is called" do

    defmodule TestAPI4 do
      use EXRequester

      @get "user/{id}"
      defreq get_status(id: id)
    end

    assert_raise(RuntimeError,
    "You are trying to call the wrong function\nget_status(client)\nplease instead call:\nget_status(id: id)",
    fn ->
      TestAPI4.client("https://httpbin.org/")
      |> TestAPI4.get_status
    end)

    assert_raise(RuntimeError,
    "You are trying to call the wrong function\nget_status(id: id, name: name)\nplease instead call:\nget_status(id: id)",
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
        defreq get_status(id: id)
      end
    end)

  end

end
