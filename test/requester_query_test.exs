
defmodule RequesterQueryTest do
  use ExUnit.Case

  test "it return error if header keys are missing" do

    defmodule TestAPI5 do
      use Requester

      @query [:sort, :filter]
      @get "user/{id}"
      defreq get_status(id: id, sort: sort, filter: filter)
    end

    TestAPI5.client("https://httpbin.org")
    |> TestAPI5.get_status(id: 1, sort: "ascending")
    assert_received {:request, [get: "https://httpbin.org/user/1?sort=ascending", headers: []]}

    TestAPI5.client("https://httpbin.org")
    |> TestAPI5.get_status(id: 1, sort: "ascending", filter: "all")
    assert_received {:request, [get: "https://httpbin.org/user/1?sort=ascending&filter=all", headers: []]}

    TestAPI5.client("https://httpbin.org")
    |> TestAPI5.get_status(id: 1)
    assert_received {:request, [get: "https://httpbin.org/user/1", headers: []]}
  end
end
