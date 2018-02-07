# ServiceLogging

[![](https://ci.solanolabs.com:443/savedo/service_logging/badges/branches/master?badge_token=213679f6ef1e1b521a496a77ddce1d7cf4316622)](https://ci.solanolabs.com:443/savedo/service_logging/suites/707867)

Contains some common setup used around logging infrastructure in multiple Savedo applications.

## Installation

Add these lines to your application's Gemfile:

```ruby
gem "service_logging", git: "https://github.com/Savedo/service_logging" # specify `tag: "v0.2.0"` to use a specific version
```

And then execute:

```
$ bundle
```

## Usage

To enable the gem, set up the `enabled` option either per environment or globally in your `config/application.rb`:

```ruby
config.service_logging.enabled = true
```

### Configuration

#### Custom payload parameters

To send custom data with payload add `append_info_to_payload` method to your controller:

```ruby
class ApplicationController
  # ...
  # modify ActionController::Instrumentation method to add custom data to payload
  private def append_info_to_payload(payload)
    super
    payload[:customer_id] = current_customer&.id
  end
  # ...
end
```

and define parameter names in the configuration:

```ruby
config.service_logging.custom_payload_params = %i(customer_id customer_email)
```

#### Logging json-api request and response

Call `AppendInfoToPayload#execute` inside of `append_info_to_payload` method:

```ruby
private def append_info_to_payload(payload)
  super
  # ...
  ServiceLogging::AppendInfoToPayload.execute(payload, request, response)
end
```

Keep in mind that `AppendInfoToPayload` works only with JSON based request/response.

#### Filtering sensitive logs

You can set up filtering of json attributes in request/response by using
[JSONPath](http://goessner.net/articles/JsonPath/) notation:

```ruby
config.service_logging.filters = {
  request_filters: [
    "$..password",
  ],
  response_filters: [
    "$.data[?(@.type=='tokens')].id"
  ]
}
```

Additionally, you can also filter request and response:

```ruby
config.service_logging.filters = {
  response_header_filters: ["Set-Cookie"],
  request_header_filters: %w(HTTP_COOKIE HTTP_AUTHORIZATION)
}
```

#### Set any Lograge config option

Do that via `config.service_logging.lograge`:

```ruby
config.service_logging.lograge.ignore_actions = %w(HomeController#index)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt
that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Savedo/service_logging.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
