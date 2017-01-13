require "service_logging/version"
require "service_logging/masking"
require "service_logging/sensitive_data_json_filter"
require "service_logging/log_filter"
require "service_logging/append_info_to_payload"

module ServiceLogging
  module_function

  mattr_accessor :filters

  def setup(app)
    require "lograge"

    app.config.lograge.enabled = true
    app.config.lograge.formatter = Lograge::Formatters::Logstash.new
    app.config.lograge.log_level = :error
    app.config.lograge.custom_options = ServiceLogging.custom_options_callback

    self.filters = app.config.service_logging.filters
  end

  def custom_options_callback
    lambda do |event|
      payload = event.payload

      data = {}
      custom_payload_params = Rails.application.config.service_logging.custom_payload_params
      custom_payload_params&.each do |param|
        data[param] = payload[param]
      end

      data.merge!(
        request_body: payload[:request_body],
        request_headers: payload[:request_headers],
        response_body: payload[:response_body],
        response_headers: payload[:response_headers]
      ).reject { |_key, val| val.blank? }

      # request_body and params contain the same information, so there is need to
      # log params, if request_body already is present.
      unless data[:request_body]
        data[:params] = payload[:params].reject { |key, _val| key.in?(%w(controller action)) }
      end

      data
    end
  end
end

require "service_logging/railtie" if defined?(Rails)
