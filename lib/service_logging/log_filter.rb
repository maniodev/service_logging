module ServiceLogging
  # Filters sensitive information in requests and responses of API
  # endpoints, so they can be safely written to logs.
  class LogFilter < SensitiveDataJsonFilter
    def initialize
      super(ServiceLogging.filters)
    end
  end
end
