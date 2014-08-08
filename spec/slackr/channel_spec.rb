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
        expect(subject).to receive(:service_url).and_return(bad_url)
        expect {
          subject.list
        }.to raise_error
      end
    end
  end

  describe "#history" do
    let(:history_body) do
      {
        "ok"       => true,
        "messages" => [
          {
            "user"       => "U02FBRY5Z",
            "type"       => "message",
            "subtype"    => "channel_join",
            "text"       => "<@U02FBRY5Z|USER> has joined the channel",
            "ts"         =>"1407368222.000037"
          }
        ],
        "has_more" => false
      }
    end
    let(:good_channel) { "goodChannel" }
    let(:bad_channel)  { "badChannel" }

    before do
      stub_request(:get, "https://team.slack.com/api/channels.history?token=fakeToken&channel=#{bad_channel}").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(:status => 404, :body => "", :headers => {})

      stub_request(:get, "https://team.slack.com/api/channels.history?token=fakeToken&channel=#{good_channel}").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => history_body.to_json, :headers => {})
    end
    it "requests the history of a channel" do
      expect(subject.history(good_channel)).to eq(history_body) #TODO: Should this be JSON.parse(history_body.to_json)? why?
    end
    context "with a bad request" do
      it "raises an error" do
        expect{subject.history(bad_channel)}.to raise_error
      end
    end
  end
end

