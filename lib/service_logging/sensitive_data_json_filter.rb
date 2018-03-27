module ServiceLogging
  # Provides methods to filter request body, request headers, response body
  # and response headers to hide sensitive information.
  # Usually is used for logging.
  #
  # @example
  #   filter = Filter.new(
  #     request_filters: ["$.api_key"],
  #     request_header_filters: ["X-TOKEN"]
  #   )
  #
  #   filter.filter_request('{"api_key":"bigsecret","data":"abc"}')
  #   # => '{"api_key":"*****ret","data":"abc"}'
  #
  #   filter.filter_headers("X-TOKEN" => "abcdefgh", "Agent" => "blabla")
  #   # => { "X-TOKEN" => "*****fgh", "Agent" => "blabla" }
  class SensitiveDataJsonFilter
    attr_reader :request_filters, :request_header_filters, :response_filters, :response_header_filters

    # @param request_filters [Array<String>] JsonPath selectors to filter request body
    # @param request_header_filters [Array<String>] names of request headers to filter
    # @param response_filters [Array<String>] JsonPath selectors to filter response body
    # @param response_header_filters [Array<String>] names of response headers to filter
    def initialize(request_filters: [], request_header_filters: [], response_filters: [], response_header_filters: [])
      @request_filters = request_filters
      @request_header_filters = request_header_filters
      @response_filters = response_filters
      @response_header_filters = response_header_filters
    end

    # @param headers [Hash]
    #
    # @return [Hash]
    def filter_request_headers(headers)
      filter_headers(headers, request_header_filters)
    end

    # @param headers [Hash]
    #
    # @return [Hash]
    def filter_response_headers(headers)
      filter_headers(headers, response_header_filters)
    end

    # Apply +request_filters+ on the given JSON/hash.
    #
    # @param data [String, Hash] JSON or hash
    #
    # @return [String, Hash] JSON or hash (depends input param)
    def filter_request(data)
      filter_body(data, request_filters)
    end

    # Apply +response_filters+ on the given JSON/hash.
    #
    # @param data [String, Hash] JSON or hash
    #
    # @return [String, Hash] JSON or hash (depends input param)
    def filter_response(data)
      filter_body(data, response_filters)
    end

    # @param data [Hash, String] hash or JSON
    # @param filters [Array<String>] array of JsonPath selectors
    #
    # @return [Hash, String] hash or JSON
    private def filter_body(data, filters)
      return data if filters.empty?

      if data.is_a?(Hash)
        filter_hash_body(data, filters)
      else
        filter_json_body(data, filters)
      end
    end

    private def filter_json_body(json, filters)
      json_path = JsonPath.for(json)
      apply_filters!(json_path, filters)
      json_path.to_hash.to_json
    rescue MultiJson::ParseError, JSON::ParserError
      json
    end

    private def filter_hash_body(hash, filters)
      json_path = JsonPath.for(hash.deep_dup)
      apply_filters!(json_path, filters)
      json_path.to_hash
    end

    private def apply_filters!(json_path, filters)
      filters.each do |path|
        json_path.gsub!(path) { |val| Masking.mask(val) }
      end
      json_path
    end

    # @param headers [Hash]
    # @param names [Array<String>] list of headers to be filtered
    #
    # @return [Hash] filtered headers
    private def filter_headers(headers, names)
      return headers if names.empty?

      filtered_headers = headers.dup
      names.each do |name|
        filtered_headers[name] = Masking.mask(headers[name]) if headers[name]
      end
      filtered_headers
    end
  end
end
