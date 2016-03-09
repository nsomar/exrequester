<p align="center">
<img src="https://raw.githubusercontent.com/oarrabi/exrequester/master/res/logo.png" width="500" align="middle"/>
<br/>
<br/>
<br/>
</p>
[![Build Status](https://travis-ci.org/oarrabi/exrequester.svg?branch=master)](https://travis-ci.org/oarrabi/exrequester)
[![Hex.pm](https://img.shields.io/hexpm/v/exrequester.svg)](https://hex.pm/packages/exrequester)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/exrequester/)
[![Coverage Status](https://coveralls.io/repos/github/oarrabi/exrequester/badge.svg?branch=master)](https://coveralls.io/github/oarrabi/exrequester?branch=master)
[![Inline docs](http://inch-ci.org/github/oarrabi/exrequester.svg?branch=master)](http://inch-ci.org/github/oarrabi/exrequester)
# EXRequester
Quickly create API clients using module attributes, inspired by [retrofit](http://square.github.io/retrofit/).
<br/>

## Installation

Add `exrequester` to your `mix.exs` deps
```elixir
def deps do
  [{:exrequester, "~> 0.1.0"}]
end
```

Then fetch your project's dependencies:
```
$ mix deps.get
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
  defreq get_picture
end
```

The above is the simplest form to define an api function.
- `@get` is used to define the relative path that will be fetched
- `{resource_id}` the resource id to use, this has to be passed when calling the function

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
  defreq get_resource

  @delete "/path/to/resource/{resource_id}"
  defreq delete_picture
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
  defreq get_resource

  @put "/path/to/resource/{resource_id}"
  defreq put_resource

  @delete "/path/to/resource/{resource_id}"
  defreq delete_resource
end
```

### Handling request body
Body is handled as a normal parameter
```elixir
defmodule SampleAPI do
  use EXRequester

  @post "/path/to/resource/{resource_id}"
  defreq post_picture
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
  defreq get_resource
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
  defreq get_resource
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
  defreq get_resource
end
```
Calling `SampleAPI.get_resource` will perform a request that always sends these headers:
```
Accept: application/json
Accept-Language: en-US
```

Notice the use of quotes in the `"Accept-Language"`. This is needed since `Accept-Language` is not a valid atom name. In order to solve that, add quotation around atoms.

### Decoding HTTP Response
`EXRequester` allows you to define a parse function/block to be used as a parser for the resceived response.
The parser can be set in three ways.

First: You can pass the anonymouse function at the function definition, For example:

```elixir
defmodule SampleAPI do
  ....
  defreq get_resource(fn response ->
    "Value is " <> response.body
  end)
end
```

When calling `get_resource` the HTTP response of type `EXRequester.Response` will be sent to the passed anonymous function.
Using this way, you can create a response decoder in place.

Second: By defining a body to the get_resource function, inside this body, you can use `response` object which will be injected by the macro

```elixir
defmodule SampleAPI do
  ....
  defreq get_resource do
    "Value is " <> response.body
  end
end
```

`response` will be set by the macro to the value of the `EXRequester.Response` received.

Alternatively, you can pass a response decoder when calling the method pass a decoder as a parameter when calling `get_resource` For example:

```elixir
SampleAPI.client("http://base_url.com")
|> SampleAPI.get_resource(resource_id: 123, auth: "1", decoder: fn response ->
  # Parse the response and return a new one
  "Response is " <> response.body
end)
```

The anonymous function passed to decoder will receive an `EXRequester.Response` structure. The anonymous function can parse the response and return a new response.
The returned new parsed response will finally returned from `get_resource`.

In the above example, the return value will be `"Response is The body content"`


### Handle response
Hitting any request will return a `EXRequester.Response` strucutre.
This structure contains `headers`, `status_code` and `body`

The body will not be parsed and will be returned as is.


## Runtime safty
When calling the wrong method at runtime, `exrequester` will fail with a descriptive message.

For example:
```elixir
@get "/path/to/resource/{resource_id}"
defreq get_resource
```
If you wrongly call the method as:
```elixir
AMod.client("http://localhost:9090/")
|> AMod.get_resource(key: 123)
```

The following error will be raised:
```elixir
** (RuntimeError) You are trying to call the wrong function
get_resource(client, key: key)
please instead call:
get_resource(client, resource_id: resource_id)
```
The error will inform you about the correct method invocation

## Future improvments
- Ability to set the URL in the function definition instead
