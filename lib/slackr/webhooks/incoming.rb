require "net/http"
require "net/https" # Obsolete as of what ruby version?
require "uri"
require "json"

module Slackr
  module IncomingWebhook
    extend self

    attr_accessor :connection

    # {
    #   :formatter => [BasicFormatter, LinkFormatter, AttachmentFormatter]
    # }
    def say(connection, text="", options={})
      @connection = connection
      #formatter = options[:formatter] || BasicFormatter
      #text      = format_text(formatter, text)
      #TODO: fix law of demeter violations
      request      = Net::HTTP::Post.new(service_url)
      request.body = encode_message(text, options)
      response     = connection.http_request(request)
      if response.code != "200"
        raise Slackr::ServiceError, "Slack.com - #{response.code} - #{response.body}"
      end
    end

  private

    def service_url
      "#{connection.base_url}/services/#{connection.token}"
    end

    def encode_message(text, options)
      #TODO: extract OptionValidator
      #TODO: add guard against invalid options
      #TODO: add guard against nil text
      connection.options.merge(options).merge({"text" => text}).to_json.to_s
    end
  end
end
