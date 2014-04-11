require 'spec_helper'

describe Slackr::IncomingWebhook do
  let(:client) { Slackr::IncomingWebhook.new("team","token") }
  subject { client }

  describe "#say" do
    it "should call Webhook#send_request with proper options" do
      msg  = "This is a test message"
      opts = {"channel" => "#somewhere"}

      subject.should_receive(:send_request).with(msg,opts)
      subject.say msg,opts
    end
  end

  describe "#service_url" do
    it "should generate the right url" do
      team    = "my-team"
      token   = "my-token"
      subject = Slackr::IncomingWebhook.new(team,token)

      subject.send(:service_url).should eq "https://#{team}.slack.com/services/hooks/incoming-webhook?token=#{token}"
    end
  end

  describe "#encode_message" do
    it "should encode a basic message" do
      msg = "this is my awesome message"

      subject.send(:encode_message,msg,{}).should eq "payload={\"text\":\"#{msg}\"}"
    end

    it "should encode a message with options" do
      msg  = "this is my awesome message"
      opts = {"channel" => "#awesometown"}

      subject.send(:encode_message,msg,opts).should eq "payload={\"channel\":\"#awesometown\",\"text\":\"#{msg}\"}"
    end

    it "should encode a basic message when there are default options" do
      msg = "this is my awesome message"

      subject.stub(:default_options).and_return({"icon_emoji" => "ghost"})
      subject.send(:encode_message,msg,{}).should eq "payload={\"icon_emoji\":\"ghost\",\"text\":\"#{msg}\"}"
    end

    it "should encode a message with option when there are default options present" do
      msg  = "this is my awesome message"
      opts = {"channel" => "#awesometown"}

      subject.stub(:default_options).and_return({"icon_emoji" => "ghost"})
      subject.send(:encode_message,msg,opts).should eq "payload={\"icon_emoji\":\"ghost\",\"channel\":\"#awesometown\",\"text\":\"#{msg}\"}"
    end
  end

end
