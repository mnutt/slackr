require 'spec_helper'

describe Slackr::IncomingWebhook do
  let(:client) { Slackr::IncomingWebhook.new("team","token") }
  subject { client }

  context "Public API" do
    #TODO: move out of webhook
    describe "#init" do
      it "should validate the options passed to the constructor" do
        expect(subject).to receive(:validate_options)
        subject.init
      end

      it "should setup a reusable connection" do
        expect(subject).to receive(:setup_connection)
        subject.init
      end
    end

    describe "#say" do
      it "should send the request, posting the message in the channel" do
        text    = "This is a test message"
        options = {"channel" => "#somewhere"}

        expect(subject).to receive(:send_request).with(text, options)
        subject.say(text, options)
      end
    end
  end

  context "Private API" do
    describe "#validate_options" do
      it "should make sure certain keys exist"

      it "should remove unused keys"
    end

    #TODO: move out of webhook
    describe "#setup_connection" do
      it "should set params on new HTTP connection" do
        expect(subject.uri).to eq(nil)
        expect(subject.http).to eq(nil)
        subject.send(:setup_connection)
        expect(subject.uri).to_not eq(nil)
        expect(subject.http).to_not eq(nil)
      end

      it "should set a proper host and port", :focus => true do
        subject.setup_connection
      end
    end

    describe "#service_url" do
      it "should generate the right url" do
        team    = "my-team"
        token   = "my-token"
        subject = Slackr::IncomingWebhook.new(team, token)

        result = subject.send(:service_url)
        expect(result).to eq "https://#{team}.slack.com/services/hooks/incoming-webhook?token=#{token}"
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

        subject.stub(:default_options).and_return({"icon_emoji" => "ghost"})
        result = subject.send(:encode_message, text, {})
        expect(result).to eq("payload={\"icon_emoji\":\"ghost\",\"text\":\"#{text}\"}")
      end

      it "should encode a message with option when there are default options present" do
        text    = "this is my awesome message"
        options = {"channel" => "#awesometown"}

        subject.stub(:default_options).and_return({"icon_emoji" => "ghost"})
        result = subject.send(:encode_message, text, options)
        expect(result).to eq("payload={\"icon_emoji\":\"ghost\",\"channel\":\"#awesometown\",\"text\":\"#{text}\"}")
      end
    end
  end
end
