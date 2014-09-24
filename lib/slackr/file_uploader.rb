require "net/http"
require "net/https"
require 'net/http/post/multipart'
require "uri"

module Slackr
  class FileUploader

    attr_accessor :connection
    attr_reader :channels, :filetype, :filename, :title, :comment, :filepath

    def initialize(connection, filepath, options={})
      @connection  = connection
      @filepath    = filepath
      @channels    = options['channels']
      @filetype    = options['filetype']
      @filename    = options['filename']
      @title       = options['title']
      @comment     = options['initial_comment']
    end

    def upload
      response = connection.http_request(multipart)
      if response.code != "200"
        raise Slackr::ServiceError, "Slack.com - #{response.code} - #{response.body}"
      end

      true
    end

  private

    def multipart
      Net::HTTP::Post::Multipart.new(service_url.path,
        {
         'file'  => UploadIO.new(File.open(filepath), "application/data"),
         'token' => connection.token
        }.merge(additional_params))
    end

    def additional_params
      {}.tap do |hash|
        hash['channels']        = channels if channels
        hash['filetype']        = filetype if filetype
        hash['filename']        = filename if filename
        hash['title']           = title    if title
        hash['initial_comment'] = comment  if comment
      end
    end

    def service_url
      URI.parse("#{connection.base_url}/api/files.upload")
    end
  end
end

