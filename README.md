# Slackr

A simple gem for sending messages to the Slack.com communications platform.

## Installation

Add this line to your application's Gemfile:

    gem 'slackr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slackr

## Usage

Send a message to slack:

```
require 'slackr'
slack = Slackr.connect("teamX", "token124", {"channel" => "#myroom", "username" => "systems_bot"})
slack.say "hello world" # posts 'hello world' to the myroom channel as the systems_bot user
slack.say "hello", {"channel" => "#room2", "username" => "joke_bot"} # posts 'hello' to the room2 channel as the joke_but user
```

Available customizations include:

```
# slack_options
# {
#   "channel"    => "#myroom",
#   "username"   => "my_bot_name",
#   "icon_url"   => "https://slack.com/img/icons/app-57.png",
#   "icon_emoji" => ":ghost:"
# }
```

## General Notes
- Slackr::Connection stores the connection information
- Slackr::Errors stores the various custom errors thrown
- Slackr::Version stores the gem version
- Slackr::IncomingWebhook stores the logic for the various incoming webhook API endpoints

## TODO

[] Support formats for incoming webhook messages
[] Link parsing and attachments
[] CLI

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
