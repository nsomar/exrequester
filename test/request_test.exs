
defmodule EXRequester.RequestTests do
  use ExUnit.Case
  alias  EXRequester.Request

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

  test "handle headers ingoring the textual headers" do
    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_headers_keys([Authorization: :auth, Key1: "The Value Is 123"])

    assert Request.prepared_headers(r, [auth: "blabla123blabla", key1: "The Value Is 123"]) ==
    [Authorization: "blabla123blabla", Key1: "The Value Is 123"]
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

  test "handle prepares a body" do
    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_body("string body")

    assert Request.prepared_body(r) == "string body"

    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_body([1, 2, 3])

    assert Request.prepared_body(r) == "[1,2,3]"

    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_body(["value1", "value2"])

    assert Request.prepared_body(r) == "[\"value1\",\"value2\"]"

    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_body(%{key1: "value1", key2: "value2"})

    assert Request.prepared_body(r) == "{\"key2\":\"value2\",\"key1\":\"value1\"}"

    r = Request.new(method: :get, path: "users/{id}/repo/{repo_id}")
    |> Request.add_body(%{"key1" => "value1", "key2" => "value2"})

    assert Request.prepared_body(r) == "{\"key2\":\"value2\",\"key1\":\"value1\"}"
  end

  test "test has_params" do
    assert Request.new(method: :get, path: "users/{id}")
    |> Request.add_query_keys([:q1, :q2])
    |> Request.add_headers_keys([h1: :v1])
    |> Request.has_params == true

    assert Request.new(method: :get, path: "users")
    |> Request.add_query_keys([:q1, :q2])
    |> Request.add_headers_keys([h1: :v1])
    |> Request.has_params == true

    assert Request.new(method: :get, path: "users")
    |> Request.add_query_keys([])
    |> Request.add_headers_keys([h1: :v1])
    |> Request.has_params == true

    assert Request.new(method: :get, path: "users")
    |> Request.add_headers_keys([h1: :v1])
    |> Request.has_params == true

    assert Request.new(method: :get, path: "users")
    |> Request.add_query_keys([:q1, :q2])
    |> Request.has_params == true

    assert Request.new(method: :get, path: "users/{id}")
    |> Request.has_params == true

    assert Request.new(method: :get, path: "users")
    |> Request.has_params == false
    
  end
end
