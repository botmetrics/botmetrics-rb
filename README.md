# Botmetrics

Botmetrics is a Ruby client to the
[BotMetrics](https://getbotmetrics.com) service which lets you collect
&amp; analyze metrics for your bot.

[![Build
Status](https://travis-ci.org/botmetrics/botmetrics-rb.svg?branch=master)](https://travis-ci.org/botmetrics/botmetrics-rb)

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
to "Bot Settings" and find out your Bot ID and API Key.

With that, you can initialize a `BotMetrics::Client`:

```ruby
client = BotMetrics::Client.new(api_key: '123', bot_id: '123')
```

Alternatively, you can set the following ENV variables

- `ENV['BOTMETRICS_API_KEY']`
- `ENV['BOTMETRICS_BOT_ID']`
- `ENV['BOTMETRICS_API_HOST']`

and initialize a `BotMetrics::Client` with the default ENV variables:

```ruby
client = BotMetrics::Client.new
```

### `register_bot!`

With a `BotMetrics::Client` instance,
every time you create a new Slack Bot (in the OAuth2 callback),
and assuming the bot token you received as part of the OAuth2 callback is `bot-token`,
you can make the following call:

```ruby
client = BotMetrics::Client.new(api_key: '123', bot_id: '123')
client.register_bot!('bot-token')
```

#### Retroactive Registration

If you created your bot in the past, you can pass in `created_at` with
the UNIX timestamp of when your bot was created, like so:

```ruby
client = BotMetrics::Client.new(api_key: '123', bot_id: '123')
client.register_bot!('bot-token', created_at: 1462318092)
```

### `message`

You can send messages to a Slack channel or user using the `#message` method:

#### Sending a Message to a Channel

```ruby
client = BotMetrics::Client.new(api_key: '123', bot_id: '123')
client.message(team_id: 'T123', channel: 'C123', text: 'Hello!')
```

#### Sending an Attachment to a User

```ruby
client = BotMetrics::Client.new(api_key: '123', bot_id: '123')
client.message(
  team_id: 'T123',
  user: 'U123',
  attachments:
    [
      {
          "title": "Title",
          "pretext": "Pretext _supports_ mrkdwn",
          "text": "Testing *right now!*",
          "mrkdwn_in": ["text", "pretext"]
      }
    ]
)
```

Accepted parameters include:

- `team_id`: This is the Slack ID
- `channel`: This is the Slack channel's UID
- `user`: This is the Slack user's UID
- `text`: A string
- `attachments`: Attachments that follows the Slack's [message attachment structure](https://api.slack.com/docs/attachments)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment with the gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/botmetrics/botmetrics-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
