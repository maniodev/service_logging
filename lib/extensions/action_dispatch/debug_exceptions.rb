require "active_support/concern"
require "action_dispatch/http/mime_type"
require "action_dispatch/middleware/debug_exceptions"

ActionDispatch::DebugExceptions.class_eval do
  alias_method :old_log_error, :log_error

  def log_error(request, wrapper)
    exception = wrapper.exception
    if exception.is_a?(ActionController::RoutingError)
      data = {
        method: request.method,
        path: request.original_fullpath,
        status: wrapper.status_code,
        error: "#{exception.class.name}: #{exception.message}"
      }
      formatted_message = Lograge.formatter.call(data)
      logger(request).send(Lograge.log_level, formatted_message)
    else
      old_log_error(request, wrapper)
    end
  end
end