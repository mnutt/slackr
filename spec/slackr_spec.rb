require 'spec_helper'

describe Slackr do
  describe "#say" do
    it "should delegate to the IncomingWebhook" do
      subject = Slackr.connect("foo", "bar", {"channel" => "#general", "username" => "baz"})
      expect(Slackr::IncomingWebhook).to receive(:say)
      subject.say("hello world", {})
    end
  end
end

