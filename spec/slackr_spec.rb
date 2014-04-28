require 'spec_helper'

describe Slackr do
  describe "#say" do
    it "should delegate to the IncomingWebhook" do
      subject = Slackr.connect("foo", "bar", {"channel" => "#general", "username" => "baz"})
      expect(Slackr::IncomingWebhook).to receive(:say)
      subject.say("hello world", {})
    end
  end

  describe "Webook.new" do
    it "should allow backwards compatibility" do
      expect(Slackr).to receive(:connect)
      Slackr::Webhook.new("team", "token")
    end
  end
end

