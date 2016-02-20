
defmodule Requester.RequestTest do
  use ExUnit.Case
  alias  Requester.Request

  test "joins strings correctly" do
    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_base_url("https://my_server.com/1")
    assert Request.prepared_url(r, [id: 2, repo_id: 2]) == "https://my_server.com/1/users/2/repo/2"

    r = Request.new(method: :get, path: "/users/{id}/repo/{repo_id}")
    |> Request.add_base_url("https://my_server.com/1")
    assert Request.prepared_url(r, [id: 2, repo_id: 2]) == "https://my_server.com/1/users/2/repo/2"

    r = Request.new(method: :get, path: "/users/{id}/repo/{repo_id}")
    |> Request.add_base_url("https://my_server.com/1/")
    assert Request.prepared_url(r, [id: 2, repo_id: 2]) == "https://my_server.com/1/users/2/repo/2"

    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_base_url("https://my_server.com/1/")
    assert Request.prepared_url(r, [id: 2, repo_id: 2]) == "https://my_server.com/1/users/2/repo/2"
  end

  test "gets the full url" do
    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_base_url("https://my_server.com/1/")

    assert Request.prepared_url(r, [id: 2, repo_id: 2]) == "https://my_server.com/1/users/2/repo/2"
  end

  test "handle headers" do
    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_headers_keys([Authorization: :auth, Key1: :key1])

    assert Request.prepared_headers(r, [auth: "blabla123blabla", key1: "Value1"]) ==
    [Authorization: "blabla123blabla", Key1: "Value1"]
  end

  test "handle query" do
    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_base_url("https://my_server.com/1/")
    |> Request.add_query_keys([:sort, :filter])

    assert Request.prepared_url(r, [id: 2, repo_id: 2]) == "https://my_server.com/1/users/2/repo/2"

    assert Request.prepared_url(r, [id: 2, repo_id: 2, sort: "ascending"])
    == "https://my_server.com/1/users/2/repo/2?sort=ascending"

    assert Request.prepared_url(r, [id: 2, repo_id: 2, sort: "ascending", filter: "all"])
    == "https://my_server.com/1/users/2/repo/2?sort=ascending&filter=all"
  end

  test "handle prepares a query" do
    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_base_url("https://my_server.com/1/")
    |> Request.add_query_keys([:sort, :filter])

    assert Request.prepared_query(r, [otehr: "ascending"]) == ""
    assert Request.prepared_query(r, [sort: "ascending"]) == "sort=ascending"
    assert Request.prepared_query(r, [sort: "ascending", other: ""]) == "sort=ascending"
    assert Request.prepared_query(r, [sort: "ascending", filter: "all"]) == "sort=ascending&filter=all"
  end

end
