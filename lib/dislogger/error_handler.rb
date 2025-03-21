# frozen_string_literal: true

require 'active_record'

module Dislogger
  module ErrorHandler
    extend ActiveSupport::Concern

    included do
      if ancestors.include?(ActionController::API) || ancestors.include?(ActionController::Base)
        # System and Runtime Errors
        rescue_from Exception, with: :handle_exception
        rescue_from StandardError, with: :handle_internal_server_error
        rescue_from RuntimeError, with: :handle_runtime_error
        rescue_from SystemStackError, with: :handle_stack_error
        rescue_from NoMemoryError, with: :handle_memory_error
        rescue_from SystemCallError, with: :handle_system_error
        rescue_from SignalException, with: :handle_signal_error
        rescue_from ScriptError, with: :handle_script_error

        # Database Errors
        rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
        rescue_from ActiveRecord::RecordNotUnique, with: :handle_conflict
        rescue_from ActiveRecord::ConnectionTimeoutError, with: :handle_timeout
        rescue_from ActiveRecord::InvalidForeignKey, with: :handle_foreign_key_error
        rescue_from ActiveRecord::ReadOnlyRecord, with: :handle_forbidden
        rescue_from ActiveRecord::StaleObjectError, with: :handle_conflict

        # Controller and Routing Errors
        rescue_from ActionController::ParameterMissing, with: :handle_unprocessable_entity
        rescue_from ActionController::InvalidAuthenticityToken, with: :handle_unauthorized
        rescue_from ActionController::UnknownFormat, with: :handle_not_acceptable
        rescue_from ActionController::UrlGenerationError, with: :handle_bad_request
        rescue_from ActionController::RoutingError, with: :handle_not_found
        rescue_from AbstractController::ActionNotFound, with: :handle_not_found

        # Authorization Errors
        rescue_from Pundit::NotAuthorizedError, with: :handle_forbidden if defined?(Pundit)
        rescue_from CanCan::AccessDenied, with: :handle_forbidden if defined?(CanCan)

        # Common Ruby Errors
        rescue_from NameError, with: :handle_internal_server_error
        rescue_from NoMethodError, with: :handle_internal_server_error
        rescue_from ArgumentError, with: :handle_bad_request
        rescue_from TypeError, with: :handle_internal_server_error
        rescue_from LoadError, with: :handle_internal_server_error
        rescue_from SyntaxError, with: :handle_internal_server_error
        rescue_from Timeout::Error, with: :handle_timeout
      end
    end

    private

    def handle_exception(exception)
      # Log detailed error information
      Rails.logger.error("[Dislogger] Unexpected error caught: #{exception.class.name}")
      Rails.logger.error("[Dislogger] Message: #{exception.message}")
      Rails.logger.error("[Dislogger] Backtrace:\n#{exception.backtrace.join("\n")}") if exception.backtrace

      notify_and_render_error(
        message: "An unexpected error occurred: #{exception.class.name} - #{exception.message}",
        status: :internal_server_error,
        backtrace: exception.backtrace
      )
    end

    def handle_runtime_error(exception)
      notify_and_render_error(
        message: "Runtime error: #{exception.message}",
        status: :internal_server_error,
        backtrace: exception.backtrace
      )
    end

    def handle_stack_error(exception)
      notify_and_render_error(
        message: "Stack overflow error: #{exception.message}",
        status: :internal_server_error,
        backtrace: exception.backtrace
      )
    end

    def handle_memory_error(exception)
      notify_and_render_error(
        message: "Out of memory error: #{exception.message}",
        status: :internal_server_error,
        backtrace: exception.backtrace
      )
    end

    def handle_system_error(exception)
      notify_and_render_error(
        message: "System error: #{exception.message}",
        status: :internal_server_error,
        backtrace: exception.backtrace
      )
    end

    def handle_signal_error(exception)
      notify_and_render_error(
        message: "Signal error: #{exception.message}",
        status: :internal_server_error,
        backtrace: exception.backtrace
      )
    end

    def handle_script_error(exception)
      notify_and_render_error(
        message: "Script error: #{exception.message}",
        status: :internal_server_error,
        backtrace: exception.backtrace
      )
    end

    def handle_not_found(exception)
      notify_and_render_error(
        message: exception.message.presence || 'Resource not found',
        status: :not_found
      )
    end

    def handle_unprocessable_entity(exception)
      errors = if exception.respond_to?(:record)
                exception.record.errors.full_messages
              elsif exception.respond_to?(:errors)
                exception.errors
              else
                [exception.message]
              end

      notify_and_render_error(
        message: 'Validation failed',
        status: :unprocessable_entity,
        details: errors
      )
    end

    def handle_conflict(exception)
      notify_and_render_error(
        message: exception.message || 'Resource conflict',
        status: :conflict
      )
    end

    def handle_timeout(exception)
      notify_and_render_error(
        message: exception.message || 'Request timeout',
        status: :request_timeout
      )
    end

    def handle_foreign_key_error(exception)
      notify_and_render_error(
        message: 'Cannot delete or update due to database constraint',
        status: :unprocessable_entity,
        details: [exception.message]
      )
    end

    def handle_unauthorized(exception)
      notify_and_render_error(
        message: exception.message || 'Unauthorized access',
        status: :unauthorized
      )
    end

    def handle_forbidden(exception)
      notify_and_render_error(
        message: exception.message.presence || 'Access forbidden',
        status: :forbidden
      )
    end

    def handle_not_acceptable(exception)
      notify_and_render_error(
        message: exception.message || 'Not acceptable',
        status: :not_acceptable
      )
    end

    def handle_bad_request(exception)
      notify_and_render_error(
        message: exception.message || 'Bad request',
        status: :bad_request
      )
    end

    def handle_internal_server_error(exception)
      notify_and_render_error(
        message: exception.message || 'Internal server error',
        status: :internal_server_error,
        backtrace: exception.backtrace
      )
    end

    def notify_and_render_error(message:, status:, details: nil, backtrace: nil)
      status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]

      notifier = Notifiers::DiscordNotifier.new
      notification_result = notifier.notify(
        message: message,
        status: status_code,
        backtrace: backtrace
      )

      Rails.logger.info("[Dislogger] Notification result: #{notification_result}") if defined?(Rails)

      render_error(message, status, details)
    end

    def render_error(message, status, details = nil)
      error_response = {
        status: status,
        message: message,
        timestamp: Time.current.utc.iso8601
      }
      error_response[:details] = details if details

      render json: error_response, status: status
    end

    private

    def filter_sensitive_params(params_hash)
      # List of sensitive parameters we don't want to show
      sensitive_params = %w[password password_confirmation token api_key secret]
      
      params_hash.deep_transform_values do |value|
        if sensitive_params.any? { |param| value.to_s.include?(param) }
          '[FILTERED]'
        else
          value
        end
      end
    end
  end
end 