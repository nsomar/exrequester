defmodule RequestParamCheckerTest do
  use ExUnit.Case

  test "it gets all params in a url" do
    url = "users/{name}/repo/{id}/{also}"
    params = RequestParamChecker.url_params(url)
    assert params == ["name", "id", "also"]
  end

  test "it checks that the params passed match the url" do
    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_params(url, [], [:name, :id, :also])
    assert res == :ok
  end

  test "it return error if there is parameter mismatch" do
    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_params(url, [], [:name, :id])

    assert res == {:error, [missing: ["also"], extra: []]}

    url = "users/{name}/repo/{id}"
    res = RequestParamChecker.check_params(url, [], [:name, :id, :also])
    assert res == {:error, [missing: [], extra: ["also"]]}
  end

  test "it works for empty params in func" do
    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_params(url, [], nil)
    assert res == {:error, [missing: ["name", "id", "also"], extra: []]}
  end

  test "it works for empty url params" do
    url = "users/repo/"
    res = RequestParamChecker.check_params(url, [], [:name])
    assert res == {:error, [missing: [], extra: ["name"]]}
  end


  test "it checks that the params passed match the url and header" do
    url = "users/{name}"
    res = RequestParamChecker.check_params(url, [:auth], [:name, :auth])
    assert res == :ok
  end

  test "it returns error if params dont match" do
    url = "users/{name}"
    res = RequestParamChecker.check_params(url, [:auth, :accept], [:name, :auth])
    assert res == {:error, [missing: ["accept"], extra: []]}

    url = "users/{name}/{some_id}"
    res = RequestParamChecker.check_params(url, [:auth], [:name, :auth])
    assert res == {:error, [missing: ["some_id"], extra: []]}

    url = "users/{name}/{some_id}"
    res = RequestParamChecker.check_params(url, [:auth], [:name, :auth, :accept])
    assert res == {:error, [missing: ["some_id"], extra: ["accept"]]}
  end

  test "it returns a method definition from params" do
    res = RequestParamChecker.propsed_method_definition(func_name: :get_users, params: [:name, :id])
    assert res == "defreq get_users(name: name, id: id)"

    res = RequestParamChecker.propsed_method_definition(func_name: :get_users, params: [])
    assert res == "defreq get_users()"

    res = RequestParamChecker.propsed_method_definition(func_name: :get_users, params: [:id])
    assert res == "defreq get_users(id: id)"
  end

  test "it returns a method invocation from params" do
    res = RequestParamChecker.propsed_method_invocation(func_name: :get_user, params: [:user, :id])
    assert res == "get_user(user: user, id: id)"
  end

  test "it prints correct parameter error" do
    res = RequestParamChecker.definition_param_error_report(missing: [:user_id], extra: [:repo_id])
    assert res ==
    {:error, "- Parameters [user_id] are missing from function definition\n- Parameters [repo_id] are ignored in the function definition"}

    res = RequestParamChecker.definition_param_error_report(missing: [], extra: [:repo_id])
    assert res ==
    {:error, "- Parameters [repo_id] are ignored in the function definition"}

    res = RequestParamChecker.definition_param_error_report(missing: [:repo_id], extra: [])
    assert res ==
    {:error, "- Parameters [repo_id] are missing from function definition"}
  end

  test "it prints :ok if no error is found in parametrs" do
    res = RequestParamChecker.definition_param_error_report(missing: [], extra: [])
    assert res == :ok
  end

  test "it reports error when function and url does not match" do
    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_definition_params(:get_status, [:name, :id, :also], url, [])
    assert res == :ok

    url = "users/{name}/repo/{id}"
    res = RequestParamChecker.check_definition_params(:get_status, [:name, :id, :also], url, [])
    assert res == {:error,
            "Function definition and url path are not matching:\nURL: users/{name}/repo/{id}\nFunction: defreq get_status(name: name, id: id, also: also)\nErrors:\n- Parameters [also] are ignored in the function definition\n\nCorrect definition: defreq get_status(name: name, id: id)"}

    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_definition_params(:get_status, [:name, :id], url, [])
    assert res == {:error,
            "Function definition and url path are not matching:\nURL: users/{name}/repo/{id}/{also}\nFunction: defreq get_status(name: name, id: id)\nErrors:\n- Parameters [also] are missing from function definition\n\nCorrect definition: defreq get_status(name: name, id: id, also: also)"}
  end

  test "it ignores body parameter in definition" do
    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_definition_params(:get_status, [:name, :id, :also, :body], url, [])
    assert res == :ok
  end

  test "it returns invocation parameter success if correct" do
    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_invocation_params(:get_status, [:name, :id, :also], url, [])
    assert res == :ok
  end

  test "it ignores body parameter in invocation" do
    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_invocation_params(:get_status, [:name, :id, :also, :body], url, [])
    assert res == :ok
  end

  test "it reports error when invocation has wrong parameters" do
    url = "users/{name}/repo/{id}"
    res = RequestParamChecker.check_invocation_params(:get_status, [:name, :id, :also], url, [])
    assert res ==  {:error, "You are trying to call the wrong function\nget_status(name: name, id: id, also: also)\nplease instead call:\nget_status(name: name, id: id)"}

    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_invocation_params(:get_status, [:name, :id], url, [])
    assert res ==  {:error, "You are trying to call the wrong function\nget_status(name: name, id: id)\nplease instead call:\nget_status(name: name, id: id, also: also)"}

    url = "users"
    res = RequestParamChecker.check_invocation_params(:get_status, [:name, :id], url, [])
    assert res == {:error, "You are trying to call the wrong function\nget_status(name: name, id: id)\nplease instead call:\nget_status()"}

    url = "users/{name}/repo/{id}/{also}"
    res = RequestParamChecker.check_invocation_params(:get_status, [], url, [])
    assert res == {:error, "You are trying to call the wrong function\nget_status()\nplease instead call:\nget_status(name: name, id: id, also: also)"}
  end

  test "it returns invocation parameter with headers success if correct" do
    url = "users/{name}/repo/{id}/"
    res = RequestParamChecker.check_invocation_params(:get_status, [:name, :id, :also], url, [:also])
    assert res == :ok
  end

  test "it reports error when invocation has wrong parameters with headers " do
    url = "users/{name}/repo"
    res = RequestParamChecker.check_invocation_params(:get_status, [:name, :id, :also], url, [:id])
    assert res ==  {:error, "You are trying to call the wrong function\nget_status(name: name, id: id, also: also)\nplease instead call:\nget_status(name: name, id: id)"}

    url = "users/{name}/repo/{id}"
    res = RequestParamChecker.check_invocation_params(:get_status, [:name, :id], url, [:also])
    assert res ==  {:error, "You are trying to call the wrong function\nget_status(name: name, id: id)\nplease instead call:\nget_status(name: name, id: id, also: also)"}

    url = "users"
    res = RequestParamChecker.check_invocation_params(:get_status, [:name, :id], url, [])
    assert res == {:error, "You are trying to call the wrong function\nget_status(name: name, id: id)\nplease instead call:\nget_status()"}

    url = "users/{name}/repo/{id}"
    res = RequestParamChecker.check_invocation_params(:get_status, [], url, [:also])
    assert res == {:error, "You are trying to call the wrong function\nget_status()\nplease instead call:\nget_status(name: name, id: id, also: also)"}
  end
end
