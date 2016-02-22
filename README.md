# EXRequester

[![Build Status](https://travis-ci.org/oarrabi/exrequester.svg?branch=master)](https://travis-ci.org/oarrabi/exrequester)
[![Coverage Status](https://coveralls.io/repos/github/oarrabi/exrequester/badge.svg?branch=master)](https://coveralls.io/github/oarrabi/exrequester?branch=master)
**TODO: Add description**


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add exrequester to your list of dependencies in `mix.exs`:

        def deps do
          [{:exrequester, "~> 0.0.1"}]
        end

  2. Ensure exrequester is started before your application:

        def application do
          [applications: [:exrequester]]
        end

## Usage

### Setting HTTP method
Define a get request endpoint
```elixir
defmodule SampleAPI do
  use EXRequester

  @get "/path/to/resource/{resource_id}"
  defreq get_resource(resource_id: resource_id)

  @delete "/path/to/resource/{resource_id}"
  defreq delete_picture(resource_id: resource_id)
end
```

Now to use it:
```elixir
SampleAPI.client("http://base_url.com")
|> SampleAPI.get_resource(resource_id: 123)

SampleAPI.client("http://base_url.com")
|> SampleAPI.post_picture(resource_id: 123, body: %{key: value})
```

This will hit
`http://base_url.com/path/to/resource/123`

Available http methods are:
```elixir
defmodule SampleAPI do
  use EXRequester

  @get "/path/to/resource/{resource_id}"
  defreq get_resource(resource_id: resource_id)

  @put "/path/to/resource/{resource_id}"
  defreq put_resource(resource_id: resource_id)

  @delete "/path/to/resource/{resource_id}"
  defreq delete_resource(resource_id: resource_id)
end
```

### Handling body
Body is handled as a normal parameter
```elixir
defmodule SampleAPI do
  use EXRequester

  @post "/path/to/resource/{resource_id}"
  defreq post_picture(resource_id: resource_id, body: body)
end
```
Body is handled in a special way based on its type.

- String bodyis sent as is
- List and map bodies is Json encode
```elixir
SampleAPI.post_picture(resource_id: 123, body: ["1", "2"])
SampleAPI.post_picture(resource_id: 123, body: %{key: value})
```
Will send json:
`[\"1\", \"2\"]`
and
`{\"key\":\"value\"}`
- Keyword list are currently ignored and will send an empty body

### Handling query
To add query to your api endpoint you would use the following:
```elixir
defmodule SampleAPI do
  use EXRequester

  @query [:sort, :filter]
  @get "/path/to/resource/{resource_id}"
  defreq get_resource(resource_id: resource_id, sort: sort, filter: filter)
end
```

You now can call the function defined with all, some or none of the query values:
```elixir
SampleAPI.client("http://base_url.com")
|> SampleAPI.get_resource(resource_id: 123)

SampleAPI.client("http://base_url.com")
|> SampleAPI.get_resource(resource_id: 123, sort: "ascending")

SampleAPI.client("http://base_url.com")
|> SampleAPI.get_resource(resource_id: 123, sort: "ascending", filter: "all")
```

These will hit the following endpoint in order:
```
http://base_url.com/path/to/resource/123

http://base_url.com/path/to/resource/123?sort=ascending

http://base_url.com/path/to/resource/123?sort=ascending&filter=all
```

### Setting headers

```elixir
defmodule SampleAPI do
  use EXRequester

  @headers [
    Authorization: :auth,
    Key1: :key1
  ]
  @get "/path/to/resource/{resource_id}"
  defreq get_resource(resource_id: resource_id, auth: auth, key1: key1)
end
```

Now to use it:
```elixir
SampleAPI.client("http://base_url.com")
|> SampleAPI.get_resource(resource_id: 123, auth1: "1", key1: "2")
```

This will hit
`http://base_url.com/path/to/resource/123`
The `Authorization` and `Key1` headers will also be set.

## Compile time and runtime safty
### Compile time safty
When definiing functions at compile time, `exrequester` will not compile if you fail to define the correct method.

For example this:
```elixir
@get "/path/to/resource/{resource_id}"
defreq get_resource()
```
When it gets compiled, it will return the following descriptive error.
```elixir
== Compilation error on file lib/http_bin_sample.ex ==
** (ArgumentError) Function definition and url path are not matching:
URL: /path/to/resource/{resource_id}
Function: defreq get_resource()
Errors:
- Parameters [resource_id] are missing from function definition

Correct definition: defreq get_resource(resource_id: resource_id)
```

The error will have the correct function definition:
```elixir
defreq get_resource(resource_id: resource_id)
```

### Runtime safty
When calling the wrong method at runtime, `exrequester` will fail with a descriptive message.

For example:
```elixir
@get "/path/to/resource/{resource_id}"
defreq get_resource(resource_id: resource_id)
```
If you wrongly call the method as:
```elixir
AMod.client("http://localhost:9090/")
|> AMod.get_resource(key: 123)
```

The following error will be raised:
```elixir
** (RuntimeError) You are trying to call the wrong function
get_resource(key: key)
please instead call:
get_resource(resource_id: resource_id)
```
The error will inform you about the correct method invocation
