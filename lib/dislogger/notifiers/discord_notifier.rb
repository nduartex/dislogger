# frozen_string_literal: true

module Dislogger
  module Notifiers
    class DiscordNotifier < BaseNotifier
      def notify(message:, status:, backtrace: nil)
        return unless enabled? && @config.discord_webhook_url.present?

        formatted_message = format_message(message, status, backtrace)
        send_notification(formatted_message)
      rescue StandardError => e
        Rails.logger.error("Discord notification failed: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n")) if e.backtrace
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
          Rails.logger.error("Discord API Error: #{response.code} - #{response.body}")
          return false
        end
        
        true
      rescue StandardError => e
        Rails.logger.error("Discord notification request failed: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n")) if e.backtrace
        false
      end

      private

      def enabled?
        @config.enabled_environments.include?(Rails.env)
      end
    end
  end
end 