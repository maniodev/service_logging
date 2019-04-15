require "service_logging/version"
require "service_logging/append_info_to_payload"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/string/starts_ends_with"
require "active_support/ordered_options"
require "kiev"

module ServiceLogging
  module_function

  mattr_accessor :enabled, :app, :kiev

  self.enabled = false
  self.kiev = ActiveSupport::OrderedOptions.new

  def setup(app) # rubocop:disable Metrics/A
    self.enabled = true
    self.app = app.config.service_logging.app

    self.kiev.enabled = app.config.service_logging.kiev.enabled || false
    configure_kiev(app) if self.kiev.enabled
  end

  def configure_kiev(app)
    self.kiev.filtered_params = app.config.service_logging.kiev.filtered_params || []
    self.kiev.ignored_params = app.config.service_logging.kiev.ignored_params || []

    Kiev.configure do |config|
      config.app = app.config.service_logging.app
      config.development_mode = app.config.service_logging.kiev.development_mode
      config.log_request_condition = proc do |request, _response|
        !%r{(^/health)}.match(request.path)
      end

      config.filtered_params = Kiev::Config::FILTERED_PARAMS | self.kiev.filtered_params
      config.ignored_params = Kiev::Config::IGNORED_PARAMS | self.kiev.ignored_params
    end
  end
end

require "service_logging/railtie" if defined?(Rails)
