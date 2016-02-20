
defmodule RequesterMethodTest do
  use ExUnit.Case

  test "it can define 2 get methods" do

    defmodule TestAPI5 do
      use Requester

      @get "user/{id}"
      defreq get_status(id: id)

      @get "user/{id}/{repo}"
      defreq get_status_with_repo(id: id, repo: repo)
    end

    TestAPI5.client("https://httpbin.org")
    |> TestAPI5.get_status(id: 1)

    assert_received {:request, [get: "https://httpbin.org/user/1", headers: []]}

    TestAPI5.client("https://httpbin.org")
    |> TestAPI5.get_status_with_repo(id: 1, repo: 2)

    assert_received {:request, [get: "https://httpbin.org/user/1/2", headers: []]}
  end

  test "it defines correct method" do
    defmodule TestAPI6 do
      use Requester

      @get "user/{id}"
      defreq get_status(id: id)

      @get "user/{id}?repo={repo}"
      defreq get_status_with_repo(id: id, repo: repo)
    end

    TestAPI6.client("https://httpbin.org")
    |> TestAPI6.get_status(id: 1)
    assert_received {:request, [get: "https://httpbin.org/user/1", headers: []]}

    TestAPI6.client("https://httpbin.org")
    |> TestAPI6.get_status_with_repo(id: 1, repo: 20)
    assert_received {:request, [get: "https://httpbin.org/user/1?repo=20", headers: []]}
  end

  test "it preforms post and put requests" do
    defmodule TestAPIA6 do
      use Requester

      @put "user/{id}"
      defreq get_status(id: id)

      @post "user/{id}?repo={repo}"
      defreq get_status_with_repo(id: id, repo: repo)
    end

    TestAPIA6.client("https://httpbin.org")
    |> TestAPIA6.get_status(id: 1)
    assert_received {:request, [put: "https://httpbin.org/user/1", headers: []]}

    TestAPIA6.client("https://httpbin.org")
    |> TestAPIA6.get_status_with_repo(id: 1, repo: 20)
    assert_received {:request, [post: "https://httpbin.org/user/1?repo=20", headers: []]}
  end

end
