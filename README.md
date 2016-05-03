# Botmetrics

Botmetrics is a Ruby client to the
[BotMetrics](https://getbotmetrics.com) service which lets you collect
&amp; analyze metrics for your bot.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'botmetrics-rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install botmetrics-rb

## Usage

Log in to your [BotMetrics](https://getbotmetrics.com) account, navigate
to "Bot Settings" and find out your Team ID, Bot ID and API Key.

Set the following environment variables with the Team ID, Bot ID and API
Key respectively.

```
BOTMETRICS_TEAM_ID=your-team-id
BOTMETRICS_BOT_ID=your-bot-id
BOTMETRICS_API_KEY=your-api-key
```

Once you have that set up, every time you create a new Slack Bot (in the
OAuth2 callback), and assuming the bot token you received as part of the
OAuth2 callback is `bot-token`, make the following call:

```ruby
BotMetrics.register_bot!('bot-token')
```

### Retroactive registration

If you created your bot in the past, you can pass in `created_at` with
the UNIX timestamp of when your bot was created, like so:

```ruby
BotMetrics.register_bot!('bot-token', created_at: 1462318092)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/botmetrics-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

