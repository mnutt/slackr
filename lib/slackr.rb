require "slackr/version"
require "slackr/errors"

require "net/http"
require "net/https" # Obsolete as of what ruby version?
require "uri"
require "json"

# slack_options
# {
#   "channel"    => "#myroom",
#   "username"   => "my_bot_name",
#   "icon_url"   => "https://slack.com/img/icons/app-57.png",
#   "icon_emoji" => ":ghost:"
# }

module Slackr

  class Client
    attr_reader :http, :uri, :default_options

    def initialize(team,token,options={})
      raise Slackr::ArgumentError, "Team required" if team.nil?
      raise Slackr::ArgumentError, "Token required" if token.nil?

      @team            = team
      @token           = token
      @default_options = options

      setup_connection
    end

    def say(text="",options={})
      # reformat links, etc here
      send_request(text,options)
    end

    private
    def setup_connection
      @uri = URI.parse(service_url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    def service_url
      "https://#{@team}.slack.com/services/hooks/incoming-webhook?token=#{@token}"
    end

    def encode_message(text,options)
      "payload=#{default_options.merge(options).merge({"text" => text}).to_json.to_s}"
    end

    def send_request(text,options)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = encode_message(text,options)
      response = http.request(request)
      unless response.code == "200"
        raise Slackr::ServiceError, "Slack.com - #{response.code} - #{response.body}"
      end
    end

  end
end
