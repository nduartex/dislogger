# frozen_string_literal: true

module Dislogger
  module Formatters
    class BaseFormatter
      def initialize(message:, status:, backtrace: nil, config: Dislogger.configuration)
        @message = message
        @status = status
        @backtrace = backtrace
        @config = config
      end

      def format
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      protected

      attr_reader :message, :status, :backtrace, :config
    end
  end
end 