require 'spec_helper'

describe Slackr::Channel do
  before do
    connection = Slackr::Connection.new('team', 'fakeToken').init
    @subject   = Slackr::Channel.init(connection)

    @list_body = {
      "ok" => true,
      "channels" => [
        {
          "id" => "C024BE91L",
          "name" => "fun",
          "created" => "1360782804",
          "creator" => "U024BE7LH",
          "is_archived" => false,
          "is_member" => false,
          "num_members" => 6,
          "topic" => {
            "value" => "Fun times",
            "creator" => "U024BE7LV",
            "last_set" => "1369677212"
          },
          "purpose" => {
            "value" => "This channel is for fun",
            "creator" => "U024BE7LH",
            "last_set" => "1360782804"
          }
        }
      ]
    }

    stub_request(:get, "https://team.slack.com/api/channel.list?token=fakeToken").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => @list_body, :headers => {})

    stub_request(:get, "https://team.slack.com/api/channel.foo?token=fakeToken").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 404, :body => "", :headers => {})
  end

  describe "#list" do
    it "requests the channel list" do
      expect(@subject.list).to eq(@list_body)
    end

    context "with a bad request" do
      it "should raise an error" do
        bad_url = "#{@subject.connection.base_url}/api/channel.foo?token=#{@subject.connection.token}"
        expect(@subject).to receive(:service_url).and_return(bad_url)
        expect {
          @subject.list
        }.to raise_error
      end
    end
  end
end

