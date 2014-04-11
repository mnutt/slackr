require "net/http"
require "net/https" # Obsolete as of what ruby version?
require "uri"
require "json"

# example:
# slack = Slackr::IncomingWebhook.new("teamX", "token123", {"channel" => "#myroom", "username" => "systems_bot"}).init
# slack.say "hello world" => posts 'hello world' to the myroom channel as the systems_bot user
# slack.say "hello", {"channel" => "#room2", "username" => "joke_bot"}
module Slackr
  class IncomingWebhook
    attr_reader :http, :uri, :default_options

    def initialize(team, token, options={})
      raise Slackr::ArgumentError, "Team required" if team.nil?
      raise Slackr::ArgumentError, "Token required" if token.nil?
      #TODO: raise error if options don't contain values

      @team            = team
      @token           = token
      #TODO: require activesupport and stringify_keys
      @default_options = options
    end

    def init
      validate_options
      setup_connection
    end

    # {
    #   :formatter => [BasicFormatter, LinkFormatter, AttachmentFormatter]
    # }
    def say(text="", options={})
      #formatter = options[:formatter] || BasicFormatter
      #text      = format_text(formatter, text)
      send_request(text, options)
    end

    private

    # slack_options
    # {
    #   "channel"    => "#myroom",
    #   "username"   => "my_bot_name",
    #   "icon_url"   => "https://slack.com/img/icons/app-57.png",
    #   "icon_emoji" => ":ghost:"
    # }
    def validate_options
      true
    end

    def setup_connection
      @uri  = URI.parse(service_url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    def service_url
      "https://#{@team}.slack.com/services/hooks/incoming-webhook?token=#{@token}"
    end

    def encode_message(text, options)
      #TODO: add guard against invalid options
      #TODO: add guard against nil text
      "payload=#{default_options.merge(options).merge({"text" => text}).to_json.to_s}"
    end

    def send_request(text, options)
      request      = Net::HTTP::Post.new(uri.request_uri)
      request.body = encode_message(text, options)
      response     = http.request(request)
      if response.code != "200"
        raise Slackr::ServiceError, "Slack.com - #{response.code} - #{response.body}"
      end
    end
  end
end
