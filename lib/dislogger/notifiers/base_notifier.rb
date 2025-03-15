# frozen_string_literal: true

module Dislogger
  module Notifiers
    class BaseNotifier
      def initialize(config = Dislogger.configuration)
        @config = config
      end

      def notify(message:, status:, backtrace: nil)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      protected

      def enabled?
        @config.enabled?
      end

      def format_message(message, status, backtrace)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def send_notification(payload)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end 