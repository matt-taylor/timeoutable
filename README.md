# Timeoutable

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'timeoutable', source: 'https://github.com/matt-taylor/timeoutable'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install timeoutable

## Usage

Take a looke at the [TestableKlass](https://github.com/matt-taylor/timeoutable/blob/main/lib/timeoutable/testable_klass.rb) for complete example.


```ruby
params = {
  warn: 10, # this can be a float
  timeout: 15, # this can be a float
  proc: ->(thread, seconds_elapsed) { thread[BIT_NAME] = 1 }, # proc to call after ${warn} seconds -- passes the original thread and the seconds that have elapsed
  message: "Error message",
}

Timeoutable.timeout(**params) do
    # code wrapped in a timeout
end
```

### How this works
After `warn` seconds have elapsed, `Timoutable` will call the `proc`. In the example, the `proc` will set a bit in the thread. However, you can choose any method of communication to gracefully shutdown.

## Development

After checking out the repo, run `make bash` to install dependencies and build a container. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/matt-taylor/timeoutable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/matt-taylor/timeoutable/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Timeoutable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/matt-taylor/timeoutable/blob/main/CODE_OF_CONDUCT.md).
