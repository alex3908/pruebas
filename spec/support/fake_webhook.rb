# frozen_string_literal: true

require "faraday"

class FakeWebhook
  def initialize(headers:, body:, host:, port:, path:)
    @headers = headers
    @body = body
    @host = host
    @port = port
    @path = path

    construct_connection
  end

  def send
    connection.post do |req|
      req.url(path)
      req.headers = headers
      req.body = JSON.generate(body)
    end
  end

  private

    attr_accessor(
      :body,
      :connection,
      :headers,
      :path,
      :session
    )

    def construct_connection
      @connection = Faraday.new(url: "http://#{@host}:#{@port}")
    end
end
