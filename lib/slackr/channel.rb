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
      make_request(request)
    end

    def history(channel)
      request  = Net::HTTP::Get.new("#{service_url('history')}&channel=#{channel}")
      make_request(request)
    end

  private

    def service_url(action)
      "#{connection.base_url}/api/channels.#{action}?token=#{connection.token}"
    end

    def make_request(request)
      response = connection.http_request(request)
      if response.code != "200"
        raise Slackr::ServiceError, "Slack.com - #{response.code} - #{response.body}"
      end
      JSON.parse(response.body)
    end
  end
end

