require "slackr/version"
require "slackr/errors"
require "slackr/connection"
require "slackr/webhooks/incoming"

# old API (soon to be deprecated):
# slack = Slackr::Webhook.new("my_team_name","my_api_key")
# slack.say "hello world"
#
# new API example:
# slack = Slackr.connect("teamX", "token123", {"channel" => "#myroom", "username" => "systems_bot"})
# slack.say "hello world" => posts 'hello world' to the myroom channel as the systems_bot user
# slack.say "hello", {"channel" => "#room2", "username" => "joke_bot"} => posts 'hello' to the room2 channel as the joke_but user
module Slackr
  extend self

  attr_accessor :connection

  def connect(team, token, options = {})
    raise Slackr::ArgumentError, "Team required"  if team.nil?
    raise Slackr::ArgumentError, "Token required" if token.nil?
    #TODO: raise error if options doesn't contain channel and username values
    @connection = Slackr::Connection.new(team, token, options).init
    return self
  end

  def say(text, options)
    Slackr::IncomingWebhook.say(connection, text, options)
  end

  # support for backwards compatibility
  class Webhook
    def initialize(team, token, options = {})
      Slackr.connect(team, token, options)
    end
  end
end

