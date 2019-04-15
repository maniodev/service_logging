module ServiceLogging
  class AppendInfoToPayload
    def self.execute(*args)
      new(*args).execute
    end

    def initialize(request, response)
      @request = request
      @response = response
    end

    def execute
      return unless ServiceLogging.enabled && ServiceLogging.kiev.enabled

      Kiev.payload(
        request_body: request_body,
        response_body: response_body,
        request_headers: request_headers,
        response_headers: response_headers
      )
    end

    private def request_body
      body = @request.body.read
      log_filter(JSON.parse(body))
    rescue JSON::ParserError
      body
    end

    private def response_body
      log_filter(JSON.parse(@response.body))
    rescue JSON::ParserError
      @response.body
    end

    private def response_headers
      log_filter(@response.headers)
    end

    # Extract HTTP request headers. Rack changes names of real headers, but original
    # headers passed to the server, start with "HTTP_".
    private def request_headers
      http_headers = @request.headers.find_all { |header, _| header.to_s.starts_with?("HTTP_") }.to_h
      log_filter(http_headers)
    end

    private def log_filter(data)
      Kiev::ParamFilter.filter(
        data,
        ServiceLogging.kiev.filtered_params,
        ServiceLogging.kiev.ignored_params
      )
    end
  end
end
