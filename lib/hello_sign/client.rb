require 'faraday'
require 'faraday_middleware-multi_json'

module HelloSign
  class Client
    API_ENDPOINT = 'https://api.hellosign.com'
    API_VERSION  = '/v3'

    attr_reader :email, :password
    attr_writer :connection

    def initialize(email, password)
      @email    = email
      @password = password
    end

    def get(path, options = {})
      request(:get, path, options)
    end

    def post(path, options = {})
      request(:post, path, options)
    end

    private

    def request(method, path, options)
      base_connection do |connection|
        connection.request :basic_auth, email, password unless options[:auth_not_required]
      end.send(method) do |request|
        request.url  "#{API_VERSION}#{path}", options[:params]
        request.body = options[:body]
      end.body
    end

    def base_connection
      Faraday.new(:url => API_ENDPOINT) do |connection|
        yield connection

        connection.request  :multipart
        connection.request  :url_encoded
        connection.response :multi_json, :symbolize_keys => true
        connection.adapter  :net_http
      end
    end

  end
end
