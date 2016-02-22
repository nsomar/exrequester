# EXRequester

[![Build Status](https://travis-ci.org/oarrabi/exrequester.svg?branch=master)](https://travis-ci.org/oarrabi/exrequester)
[![Coverage Status](https://coveralls.io/repos/github/oarrabi/exrequester/badge.svg?branch=master)](https://coveralls.io/github/oarrabi/exrequester?branch=master)

Quickly define your API functions using module attributes, inspired by [retrofit](http://square.github.io/retrofit/).

## Installation

Add `exrequester` to your mix.exs deps
```elixir
def deps do
  [{:exrequester, github: "oarrabi/exrequester"}]
end
```

## Usage

Start by adding `use EXRequester` in your module

```elixir
defmodule SampleAPI do
  use EXRequester
end
```

This will make `defreq/1` macro available. This macro takes a function name and a set of parametrs as its argument
```elixir
defmodule SampleAPI do
  use EXRequester

  @get "/path/to/resource/{resource_id}"
  defreq get_picture(resource_id: resource_id)
end
```

The above is the simplest form to define an api function.
- `@get` is used to define the relative path that will be fetched
- `{resource_id}` in the url will be replaced with the parameter `resource_id` in the defined function_name

Compiling the above will make the following functions available:
```elixir
defmodule SampleAPI do
  def client(base_url)
  def get_picture(client, resource_id: resource_id)
end
```
- `client/1` is used to set hte base url that will be used in get picture
- `get_picture/2` will execute the url, it takes the client and the parameters specified in the call to `defreq get_picture...`

For example, to call `get_picture` you would do this:
```elixir
SampleAPI.client("http://base_url.com")
|> SampleAPI.get_picture(resource_id: 123)
```



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

#### Dynamic Headers
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

#### Static Headers
Static headers are defined by using strings, instead of atom, in the `@headers` definition

```elixir
defmodule SampleAPI do
  use EXRequester

  @headers [
    Authorization: :auth,
    Accept: "application/json",
    "Accept-Language": "en-US"
  ]
  @get "/path/to/resource/{resource_id}"
  defreq get_resource(resource_id: resource_id, auth: auth)
end
```
Calling `SampleAPI.get_resource` will perform a request that always sends these headers:
```
Accept: application/json
Accept-Language: en-US
```

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
### Handle response
Hitting any request will return a `EXRequester.Response` strucutre.
This structure contains `headers`, `status_code` and `body`

The body will not be parsed and will be returned as is.

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

## Future improvments
- Ability to set the URL in the function definition instead
- Set predifined headers and send them as part of the payload
```elixir
@headers [
  Authorization: :auth,
  Key1: "Predifined will be sent as is"
]
```
