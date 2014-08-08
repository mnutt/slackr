require 'spec_helper'

describe Slackr::Channel do
  let(:connection) { Slackr::Connection.new('team', 'fakeToken').init }
  subject { Slackr::Channel.init(connection) }


  describe "#list" do
    let(:list_body) do
      {
        :ok       => true,
        :channels => [
          {
            :id          => "C024BE91L",
            :name        => "fun",
            :created     => "1360782804",
            :creator     => "U024BE7LH",
            :is_archived => false,
            :is_member   => false,
            :num_members => 6,
            :topic       => {
              :value     => "Fun times",
              :creator   => "U024BE7LV",
              :last_set  => "1369677212"
            },
            :purpose => {
              :value    => "This channel is for fun",
              :creator  => "U024BE7LH",
              :last_set => "1360782804"
            }
          }
        ]
      }
    end
    before do
      stub_request(:get, "https://team.slack.com/api/channels.list?token=fakeToken").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => list_body.to_json, :headers => {})

      stub_request(:get, "https://team.slack.com/api/channels.foo?token=fakeToken").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 404, :body => "", :headers => {})

      stub_request(:get, "https://team.slack.com/api/channels.list?token=fakeToken").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => list_body.to_json, :headers => {})
    end
    it "requests the channel list" do
      expect(subject.list).to eq(JSON.parse(list_body.to_json))
    end

    context "with a bad request" do
      it "raises an error" do
        bad_url = "#{subject.connection.base_url}/api/channel.foo?token=#{subject.connection.token}"
        expect(subject).to receive(:url_for).and_return(bad_url)
        expect {
          subject.list
        }.to raise_error
      end
    end
  end

  describe "#history" do
    let(:timestamp_1) { "1407368222.000037" }
    def message(timestamp: timestamp_1)
      {
        "user"       => "U02FBRY5Z",
        "type"       => "message",
        "subtype"    => "channel_join",
        "text"       => "<@U02FBRY5Z|USER> has joined the channel",
        "ts"         => timestamp
      }
    end
    let(:message_1) { message }
    let(:message_2) { message(timestamp: "1307368222.000037")}

    def history_body(messages: [message_1], has_more: false)
      {
        "ok"       => true,
        "messages" => messages,
        "has_more" => has_more
      }
    end
    let(:long_history_body_1) { history_body(has_more: true) }
    let(:long_history_body_2) { history_body(messages: [message_2]) }
    let(:headers) { {:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}} }

    let(:good_channel) { "goodChannel" }
    let(:bad_channel)  { "badChannel" }
    let(:long_channel) { "longChannel" }
    let(:base_history_url) {"https://team.slack.com/api/channels.history?token=fakeToken&count=1000&channel="}
    let(:bad_history_url) { "#{base_history_url}#{bad_channel}" }
    let(:good_history_url) { "#{base_history_url}#{good_channel}" }
    let(:long_history_url_1) { "#{base_history_url}#{long_channel}" }
    let(:long_history_url_2) { "#{long_history_url_1}&latest=#{timestamp_1}" }

    before do
      stub_request(:get, bad_history_url).with(headers).
        to_return(:status => 404, :body => "", :headers => {})

      stub_request(:get, good_history_url).with(headers).
        to_return(:status => 200, :body => history_body.to_json, :headers => {})

      stub_request(:get, long_history_url_1).with(headers).
        to_return(:status => 200, :body => long_history_body_1.to_json, :headers => {})
      stub_request(:get, long_history_url_2).with(headers).
        to_return(:status => 200, :body => long_history_body_2.to_json, :headers => {})
    end
    it "requests the history of a channel" do
      expect(subject.history(good_channel)).to eq(history_body) #TODO: Should this be JSON.parse(history_body.to_json)? why?
    end
    context "with lots of history" do
      it "makes enough requests to get everything" do
        expect(subject.history(long_channel)).to eq(history_body(messages: [message_1, message_2]))
        expect(WebMock).to have_requested(:get, long_history_url_1).once
        expect(WebMock).to have_requested(:get, long_history_url_2)
      end
    end
    context "with a bad request" do
      it "raises an error" do
        expect{subject.history(bad_channel)}.to raise_error
      end
    end
  end
end

