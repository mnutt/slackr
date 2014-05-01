require "net/http"
require "net/https" # Obsolete as of what ruby version?
require "uri"

# slack_options
# {
#   "channel"    => "#myroom",
#   "username"   => "my_bot_name",
#   "icon_url"   => "https://slack.com/img/icons/app-57.png",
#   "icon_emoji" => ":ghost:"
# }
module Slackr
  class Connection
    attr_accessor :http, :uri, :options, :team, :token

    def initialize(team, token, options={})
      @team, @token, @options = team, token, options
    end

    def init
      validate_options
      setup_connection
      return self
    end

    def base_url
      "https://#{@team}.slack.com"
    end

    def uri_request_uri
      uri.request_uri
    end

    def http_request(request)
      http.request(request)
    end

  private

    def validate_options
      (options.has_key?("channel") && options.has_key?("username")) && !options["channel"].match(/^#/).nil?
    end

    def setup_connection
      @uri  = URI.parse(base_url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
  end
end
