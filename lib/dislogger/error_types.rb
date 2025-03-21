# frozen_string_literal: true

module Dislogger
  # This module documents all error types handled by Dislogger
  module ErrorTypes
    # System and Runtime Errors
    SYSTEM_ERRORS = {
      Exception: {
        description: 'Base class for all exceptions',
        http_status: :internal_server_error
      },
      StandardError: {
        description: 'Base class for most Ruby errors',
        http_status: :internal_server_error
      },
      RuntimeError: {
        description: 'Generic runtime error',
        http_status: :internal_server_error
      },
      SystemStackError: {
        description: 'System stack overflow error',
        http_status: :internal_server_error
      },
      NoMemoryError: {
        description: 'Out of memory error',
        http_status: :internal_server_error
      },
      SystemCallError: {
        description: 'System call error',
        http_status: :internal_server_error
      },
      SignalException: {
        description: 'System signal-related error',
        http_status: :internal_server_error
      },
      ScriptError: {
        description: 'Script syntax or execution error',
        http_status: :internal_server_error
      }
    }.freeze

    # Database Errors (ActiveRecord)
    DATABASE_ERRORS = {
      'ActiveRecord::RecordNotFound': {
        description: 'Record not found in database',
        http_status: :not_found
      },
      'ActiveRecord::RecordInvalid': {
        description: 'Record validation failed',
        http_status: :unprocessable_entity
      },
      'ActiveRecord::RecordNotUnique': {
        description: 'Uniqueness constraint violation',
        http_status: :conflict
      },
      'ActiveRecord::ConnectionTimeoutError': {
        description: 'Database connection timeout',
        http_status: :request_timeout
      },
      'ActiveRecord::InvalidForeignKey': {
        description: 'Foreign key constraint violation',
        http_status: :unprocessable_entity
      },
      'ActiveRecord::ReadOnlyRecord': {
        description: 'Attempted to modify a read-only record',
        http_status: :forbidden
      },
      'ActiveRecord::StaleObjectError': {
        description: 'Concurrency conflict when updating record',
        http_status: :conflict
      }
    }.freeze

    # Controller and Routing Errors
    CONTROLLER_ERRORS = {
      'ActionController::ParameterMissing': {
        description: 'Required parameter not found',
        http_status: :unprocessable_entity
      },
      'ActionController::InvalidAuthenticityToken': {
        description: 'Invalid CSRF token',
        http_status: :unauthorized
      },
      'ActionController::UnknownFormat': {
        description: 'Unsupported response format',
        http_status: :not_acceptable
      },
      'ActionController::UrlGenerationError': {
        description: 'URL generation error',
        http_status: :bad_request
      },
      'ActionController::RoutingError': {
        description: 'Route not found',
        http_status: :not_found
      },
      'AbstractController::ActionNotFound': {
        description: 'Controller action not found',
        http_status: :not_found
      }
    }.freeze

    # Authorization Errors
    AUTHORIZATION_ERRORS = {
      'Pundit::NotAuthorizedError': {
        description: 'Not authorized by Pundit policies',
        http_status: :forbidden
      },
      'CanCan::AccessDenied': {
        description: 'Access denied by CanCan',
        http_status: :forbidden
      }
    }.freeze

    # Common Ruby Errors
    RUBY_ERRORS = {
      NameError: {
        description: 'Reference to undefined name',
        http_status: :internal_server_error
      },
      NoMethodError: {
        description: 'Call to undefined method',
        http_status: :internal_server_error
      },
      ArgumentError: {
        description: 'Invalid or incorrect arguments',
        http_status: :bad_request
      },
      TypeError: {
        description: 'Incorrect object type',
        http_status: :internal_server_error
      },
      LoadError: {
        description: 'Error loading dependency or file',
        http_status: :internal_server_error
      },
      SyntaxError: {
        description: 'Code syntax error',
        http_status: :internal_server_error
      },
      Timeout::Error: {
        description: 'Operation timeout',
        http_status: :request_timeout
      }
    }.freeze

    # Method to get all handled errors
    def self.all_errors
      SYSTEM_ERRORS.merge(DATABASE_ERRORS)
                   .merge(CONTROLLER_ERRORS)
                   .merge(AUTHORIZATION_ERRORS)
                   .merge(RUBY_ERRORS)
    end

    # Method to get HTTP status for a specific error type
    def self.get_status_for(error_class)
      error_info = all_errors[error_class.name.to_sym]
      error_info ? error_info[:http_status] : :internal_server_error
    end

    # Method to get description for a specific error type
    def self.get_description_for(error_class)
      error_info = all_errors[error_class.name.to_sym]
      error_info ? error_info[:description] : 'Unspecified error'
    end
  end
end 