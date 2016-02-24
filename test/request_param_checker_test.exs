defmodule EXRequest.ParamsCheckerTests do
  use ExUnit.Case

  test "it gets all params in a url" do
    url = "users/{name}/repo/{id}/{also}"
    params = EXRequest.ParamsChecker.url_params(url)
    assert params == ["name", "id", "also"]
  end

  test "it checks that the params passed match the url" do
    url = "users/{name}/repo/{id}/{also}"
    res = EXRequest.ParamsChecker.check_params(url, [], [:name, :id, :also])
    assert res == :ok
  end

  test "it return error if there is parameter mismatch" do
    url = "users/{name}/repo/{id}/{also}"
    res = EXRequest.ParamsChecker.check_params(url, [], [:name, :id])

    assert res == {:error, [missing: ["also"], extra: []]}

    url = "users/{name}/repo/{id}"
    res = EXRequest.ParamsChecker.check_params(url, [], [:name, :id, :also])
    assert res == {:error, [missing: [], extra: ["also"]]}
  end

  test "it works for empty params in func" do
    url = "users/{name}/repo/{id}/{also}"
    res = EXRequest.ParamsChecker.check_params(url, [], nil)
    assert res == {:error, [missing: ["name", "id", "also"], extra: []]}
  end

  test "it works for empty url params" do
    url = "users/repo/"
    res = EXRequest.ParamsChecker.check_params(url, [], [:name])
    assert res == {:error, [missing: [], extra: ["name"]]}
  end


  test "it checks that the params passed match the url and header" do
    url = "users/{name}"
    res = EXRequest.ParamsChecker.check_params(url, [:auth], [:name, :auth])
    assert res == :ok
  end

  test "it returns error if params dont match" do
    url = "users/{name}"
    res = EXRequest.ParamsChecker.check_params(url, [:auth, :accept], [:name, :auth])
    assert res == {:error, [missing: ["accept"], extra: []]}

    url = "users/{name}/{some_id}"
    res = EXRequest.ParamsChecker.check_params(url, [:auth], [:name, :auth])
    assert res == {:error, [missing: ["some_id"], extra: []]}

    url = "users/{name}/{some_id}"
    res = EXRequest.ParamsChecker.check_params(url, [:auth], [:name, :auth, :accept])
    assert res == {:error, [missing: ["some_id"], extra: ["accept"]]}
  end


  test "it returns a method invocation from params" do
    res = EXRequest.ParamsChecker.propsed_method_invocation(func_name: :get_user, params: [:user, :id])
    assert res == "get_user(client, user: user, id: id)"
  end

  test "it returns a method invocation from params ignoring the headers" do
    url = "users/{name}/{some_id}"
    res = EXRequest.ParamsChecker.propsed_method_invocation(func_name: :get_user, url: url, header_keys: [:key1, "Ignore this key"])
    assert res == "get_user(client, name: name, some_id: some_id, key1: key1)"
  end

  test "it returns invocation parameter success if correct" do
    url = "users/{name}/repo/{id}/{also}"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id, :also], url, [])
    assert res == :ok
  end

  test "it ignores body parameter in invocation" do
    url = "users/{name}/repo/{id}/{also}"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id, :also, :body], url, [])
    assert res == :ok
  end

  test "it ignores body decoder from invocation" do
    url = "users/{name}/repo/{id}/{also}"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id, :also, :decoder], url, [])
    assert res == :ok
  end

  test "it reports error when invocation has wrong parameters" do
    url = "users/{name}/repo/{id}"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id, :also], url, [])
    assert res ==  {:error, "You are trying to call the wrong function\nget_status(client, name: name, id: id, also: also)\nplease instead call:\nget_status(client, name: name, id: id)"}

    url = "users/{name}/repo/{id}/{also}"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id], url, [])
    assert res ==  {:error, "You are trying to call the wrong function\nget_status(client, name: name, id: id)\nplease instead call:\nget_status(client, name: name, id: id, also: also)"}

    url = "users"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id], url, [])
    assert res == {:error, "You are trying to call the wrong function\nget_status(client, name: name, id: id)\nplease instead call:\nget_status(client)"}

    url = "users/{name}/repo/{id}/{also}"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [], url, [])
    assert res == {:error, "You are trying to call the wrong function\nget_status(client)\nplease instead call:\nget_status(client, name: name, id: id, also: also)"}
  end

  test "it ignores textual headers in the invocation" do
    url = "users/{name}"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :key1], url, [:key1, "The Value is"])
    assert res == :ok
  end

  test "it returns invocation parameter with headers success if correct" do
    url = "users/{name}/repo/{id}/"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id, :also], url, [:also])
    assert res == :ok
  end

  test "it reports error when invocation has wrong parameters with headers " do
    url = "users/{name}/repo"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id, :also], url, [:id])
    assert res ==  {:error, "You are trying to call the wrong function\nget_status(client, name: name, id: id, also: also)\nplease instead call:\nget_status(client, name: name, id: id)"}

    url = "users/{name}/repo/{id}"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id], url, [:also])
    assert res ==  {:error, "You are trying to call the wrong function\nget_status(client, name: name, id: id)\nplease instead call:\nget_status(client, name: name, id: id, also: also)"}

    url = "users"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [:name, :id], url, [])
    assert res == {:error, "You are trying to call the wrong function\nget_status(client, name: name, id: id)\nplease instead call:\nget_status(client)"}

    url = "users/{name}/repo/{id}"
    res = EXRequest.ParamsChecker.check_invocation_params(:get_status, [], url, [:also])
    assert res == {:error, "You are trying to call the wrong function\nget_status(client)\nplease instead call:\nget_status(client, name: name, id: id, also: also)"}
  end

  test "it checks if function has params" do
    url = "users/{name}/repo/{id}/"
    res = EXRequest.ParamsChecker.check_has_params(url: url, headers: [header1: :value1], query: [:query1, :query2])
    assert res == true

    url = "users"
    res = EXRequest.ParamsChecker.check_has_params(url: url, headers: [header1: :value1], query: [:query1, :query2])
    assert res == true

    url = "users"
    res = EXRequest.ParamsChecker.check_has_params(url: url, headers: [header1: :value1], query: [])
    assert res == true

    url = "users"
    res = EXRequest.ParamsChecker.check_has_params(url: url, headers: [header1: ":value1"], query: [])
    assert res == false

    url = "users"
    res = EXRequest.ParamsChecker.check_has_params(url: url, headers: [], query: [])
    assert res == false
  end
end
