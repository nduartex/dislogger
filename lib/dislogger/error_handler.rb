# frozen_string_literal: true

require 'active_record'

module Dislogger
  module ErrorHandler
    extend ActiveSupport::Concern

    included do
      if ancestors.include?(ActionController::API) || ancestors.include?(ActionController::Base)
        rescue_from Exception, with: :handle_exception
        rescue_from StandardError, with: :handle_internal_server_error
        rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
        rescue_from ActionController::ParameterMissing, with: :handle_unprocessable_entity
        rescue_from Pundit::NotAuthorizedError, with: :handle_forbidden if defined?(Pundit)
        rescue_from CanCan::AccessDenied, with: :handle_forbidden if defined?(CanCan)
      end
    end

    private

    def handle_exception(exception)
      Rails.logger.error("Dislogger caught exception: #{exception.class.name} - #{exception.message}")
      Rails.logger.error(exception.backtrace.join("\n")) if exception.backtrace

      notify_and_render_error(
        message: "#{exception.class.name}: #{exception.message}",
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
      errors = exception.respond_to?(:record) ? exception.record.errors.full_messages : [exception.message]
      notify_and_render_error(
        message: 'Validation failed',
        status: :unprocessable_entity,
        details: errors
      )
    end

    def handle_forbidden(exception)
      notify_and_render_error(
        message: exception.message.presence || 'You are not authorized to perform this action',
        status: :forbidden
      )
    end

    def handle_internal_server_error(exception)
      notify_and_render_error(
        message: exception.message || 'Internal Server Error',
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

      Rails.logger.info("Dislogger notification result: #{notification_result}") if defined?(Rails)

      render_error(message, status, details)
    end

    def render_error(message, status, details = nil)
      error_response = {
        status: status,
        message: message
      }
      error_response[:details] = details if details

      render json: error_response, status: status
    end
  end
end 