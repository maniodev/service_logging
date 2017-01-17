module ServiceLogging
  class AppendInfoToPayload
    def self.execute(*args)
      new(*args).execute
    end

    def initialize(payload, request, response)
      @payload = payload
      @request = request
      @response = response
    end

    def execute
      return unless ServiceLogging.enabled

      @payload[:request_body] = request_body
      @payload[:response_body] = response_body
      @payload[:request_headers] = request_headers
      @payload[:response_headers] = response_headers
    end

    private def request_body
      body = @request.body.read
      filtered_hash = log_filter.filter_request(JSON.parse(body))
      JSON.pretty_generate(filtered_hash)
    rescue JSON::ParserError
      return body
    end

    private def response_body
      filtered_hash = log_filter.filter_response(JSON.parse(@response.body))
      JSON.pretty_generate(filtered_hash)
    rescue JSON::ParserError
      @response.body
    end

    # Extract HTTP request headers. Rack changes names of real headers, but original
    # headers passed to the server, start with "HTTP_".
    private def request_headers
      http_headers = @request.headers.find_all { |header, _| header.starts_with?("HTTP_") }.to_h
      log_filter.filter_request_headers(http_headers).to_json
    end

    private def response_headers
      log_filter.filter_response_headers(@response.headers).to_json
    end

    private def log_filter
      @log_filter ||= SensitiveDataJsonFilter.new(ServiceLogging.filters)
    end
  end
end
