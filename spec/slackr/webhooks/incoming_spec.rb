require 'spec_helper'

describe Slackr::IncomingWebhook do
  before do
    @connection = Slackr::Connection.new("team", "token", {})
    @connection.send(:setup_connection)
    stub_request(:post, "https://team.slack.com/").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})
  end

  context "Public API" do
    describe "#say" do
      it "should send the request, posting the message in the channel" do
        text       = "This is a test message"
        options    = {"channel" => "#somewhere"}
        expect(Slackr::IncomingWebhook).to receive(:encode_message)
        Slackr::IncomingWebhook.say(@connection, text, options)
      end
    end
  end

  context "Private API" do
    describe "#service_url" do
      it "should generate the right url" do
        subject.instance_variable_set(:@connection, @connection)
        result = subject.send(:service_url)
        expect(result).to eq "https://team.slack.com/services/hooks/incoming-webhook?token=token"
      end
    end

    describe "#encode_message" do
      it "should encode a basic message" do
        text = "this is my awesome message"

        result = subject.send(:encode_message, text, {})
        expect(result).to eq "payload={\"text\":\"#{text}\"}"
      end

      it "should encode a message with options" do
        text    = "this is my awesome message"
        options = {"channel" => "#awesometown"}

        result = subject.send(:encode_message, text, options)
        expect(result).to eq "payload={\"channel\":\"#awesometown\",\"text\":\"#{text}\"}"
      end

      it "should encode a basic message when there are default options" do
        text = "this is my awesome message"

        subject.connection.stub(:options).and_return({"icon_emoji" => "ghost"})
        result = subject.send(:encode_message, text, {})
        expect(result).to eq("payload={\"icon_emoji\":\"ghost\",\"text\":\"#{text}\"}")
      end

      it "should encode a message with option when there are default options present" do
        text    = "this is my awesome message"
        options = {"channel" => "#awesometown"}

        subject.connection.stub(:options).and_return({"icon_emoji" => "ghost"})
        result = subject.send(:encode_message, text, options)
        expect(result).to eq("payload={\"icon_emoji\":\"ghost\",\"channel\":\"#awesometown\",\"text\":\"#{text}\"}")
      end
    end
  end
end
