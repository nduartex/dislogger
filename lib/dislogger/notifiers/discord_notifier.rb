# frozen_string_literal: true

module Dislogger
  module Notifiers
    class DiscordNotifier < BaseNotifier
      def notify(message:, status:, backtrace: nil)
        return false unless enabled? && @config.discord_webhook_url.present?

        log_info("Attempting to send Discord notification")
        formatted_message = format_message(message, status, backtrace)
        send_notification(formatted_message)
      rescue StandardError => e
        log_error("Discord notification failed: #{e.message}")
        log_error(e.backtrace.join("\n")) if e.backtrace
        false
      end

      protected

      def format_message(message, status, backtrace)
        log_info("Formatting Discord message")
        Formatters::DiscordFormatter.new(
          message: message,
          status: status,
          backtrace: backtrace,
          config: @config
        ).format
      end

      def send_notification(payload)
        log_info("Sending notification to Discord")
        response = HTTParty.post(
          @config.discord_webhook_url,
          body: payload.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        
        unless response.success?
          error_message = "Discord API Error: #{response.code} - #{response.body}"
          log_error(error_message)
          return false
        end
        
        log_info("Discord notification sent successfully")
        true
      rescue StandardError => e
        log_error("Failed to send Discord notification: #{e.message}")
        log_error(e.backtrace.join("\n")) if e.backtrace
        false
      end

      def enabled?
        result = @config.enabled?
        log_info("Dislogger enabled? #{result} (environment: #{@config.environment}, enabled_environments: #{@config.enabled_environments})")
        result
      end

      private

      def log_info(message)
        if defined?(Rails) && Rails.logger
          Rails.logger.info("[Dislogger] #{message}")
        else
          puts "[Dislogger] #{message}"
        end
      end

      def log_error(message)
        if defined?(Rails) && Rails.logger
          Rails.logger.error("[Dislogger] #{message}")
        else
          warn "[Dislogger] #{message}"
        end
      end
    end
  end
end 