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
slack = Slackr::Client.new("my_team_name","my_api_key")
slack.send("this is a test")
```

Send a message to slack using some customization:

```
require 'slackr'
slack = Slackr::Client.new("my_team_name","my_api_key",{:icon_emoji => ":ghost:"})
slack.send("this is a test as a ghost")
slack.send("this is a test as a ghost with a custom name",{:username => "casper"}
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

## TODO

1. More/better tests
2. Link parsing and attachments
3. CLI

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
