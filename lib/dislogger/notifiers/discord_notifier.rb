# frozen_string_literal: true

module Dislogger
  module Notifiers
    class DiscordNotifier < BaseNotifier
      def notify(message:, status:, backtrace: nil)
        return unless enabled? && @config.discord_webhook_url.present?

        formatted_message = format_message(message, status, backtrace)
        send_notification(formatted_message)
      rescue StandardError => e
        if defined?(Rails) && Rails.logger
          Rails.logger.error("Discord notification failed: #{e.message}")
        else
          warn("Discord notification failed: #{e.message}")
        end
        false
      end

      protected

      def format_message(message, status, backtrace)
        Formatters::DiscordFormatter.new(
          message: message,
          status: status,
          backtrace: backtrace,
          config: @config
        ).format
      end

      def send_notification(payload)
        response = HTTParty.post(
          @config.discord_webhook_url,
          body: payload.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        
        unless response.success?
          error_message = "Discord API Error: #{response.code} - #{response.body}"
          if defined?(Rails) && Rails.logger
            Rails.logger.error(error_message)
          else
            warn(error_message)
          end
          return false
        end
        
        true
      end

      def enabled?
        @config.enabled?
      end
    end
  end
end 