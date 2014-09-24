require 'spec_helper'

describe Slackr::FileUploader do
  let(:connection) {  Slackr::Connection.new("team", "token", {}) }

  before do
    connection.send(:setup_connection)

    stub_request(:post, "https://team.slack.com/api/files.upload").
         with(:body => "-------------RubyMultipartPost\r\nContent-Disposition: form-data; name=\"file\"; filename=\"sample_file.txt\"\r\nContent-Length: 13\r\nContent-Type: application/data\r\nContent-Transfer-Encoding: binary\r\n\r\nHello world!\n\r\n-------------RubyMultipartPost\r\nContent-Disposition: form-data; name=\"token\"\r\n\r\ntoken\r\n-------------RubyMultipartPost\r\nContent-Disposition: form-data; name=\"channels\"\r\n\r\n123456789\r\n-------------RubyMultipartPost\r\nContent-Disposition: form-data; name=\"filetype\"\r\n\r\ntxt\r\n-------------RubyMultipartPost\r\nContent-Disposition: form-data; name=\"title\"\r\n\r\nsome custom title\r\n-------------RubyMultipartPost\r\nContent-Disposition: form-data; name=\"initial_comment\"\r\n\r\nsome kind of comment\r\n-------------RubyMultipartPost--\r\n\r\n",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Length'=>'725', 'Content-Type'=>'multipart/form-data; boundary=-----------RubyMultipartPost', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => "", :headers => {})
  end

  describe "#upload" do
    let(:filepath) { "spec/fixtures/sample_file.txt" }
    let(:options) { {'channels' => '123456789', 'filetype' => 'txt', 'title' => 'some custom title', 'initial_comment' => 'some kind of comment'} }

    subject { described_class.new(connection, filepath, options) }

    it "should upload the file to the specified channel" do
      expect(subject.upload).to eq true
    end
  end
end
