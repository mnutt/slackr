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
      request = request_for(url_for('list'))
      make_request(request)
    end

    def history(channel)
      request  = request_for(history_url(channel))
      response = make_request(request)
      messages = response["messages"]
      while response["has_more"] do
        oldest_timestamp = oldest_message(response["messages"])["ts"]
        request  = request_for(history_url(channel, oldest_timestamp))
        response = make_request(request)
        messages += response["messages"]
      end
      response.merge("messages" => messages)
    end

  private

    def url_for(action)
      "#{connection.base_url}/api/channels.#{action}?token=#{connection.token}"
    end

    def request_for(url)
      Net::HTTP::Get.new(url)
    end

    def history_url(channel, timestamp=nil)
      base = "#{url_for('history')}&channel=#{channel}&count=1000"
      return base unless timestamp
      "#{base}&latest=#{timestamp}"
    end

    def make_request(request)
      response = connection.http_request(request)
      if response.code != "200"
        raise Slackr::ServiceError, "Slack.com - #{response.code} - #{response.body}"
      end
      JSON.parse(response.body)
    end

    def oldest_message(messages)
      messages.min_by { |message| message["ts"]}
    end
  end
end

