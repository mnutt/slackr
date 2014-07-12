require "json"

module Slackr
  module Channel
    extend self

    attr_accessor :connection

    def init(connection)
      @connection = connection
      return self
    end

    def list
      request  = Net::HTTP::Get.new(service_url('list'))
      response = connection.http_request(request)
      if response.code != "200"
        raise Slackr::ServiceError, "Slack.com - #{response.code} - #{response.body}"
      end
      response.body
    end

  private

    def service_url(action)
      "#{connection.base_url}/api/channel.#{action}?token=#{connection.token}"
    end
  end
end

