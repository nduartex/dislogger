# frozen_string_literal: true

module Dislogger
  module Formatters
    class DiscordFormatter < BaseFormatter
      def format
        {
          username: @config.bot_username,
          embeds: [
            {
              title: format_title,
              description: format_description,
              color: get_error_color,
              fields: build_fields,
              timestamp: Time.current.utc.iso8601
            }
          ]
        }
      end

      private

      def format_title
        "#{@config.environment.capitalize} - Error Notification (#{@status})"
      end

      def format_description
        return @message if @message.is_a?(String)
        return @message.message if @message.respond_to?(:message)
        @message.to_s
      end

      def get_error_color
        @config.error_color_map[@status] || @config.error_color_map[:default]
      end

      def build_fields
        fields = [
          { name: 'Status Code', value: @status.to_s, inline: true },
          { name: 'Environment', value: @config.environment, inline: true }
        ]

        if @backtrace && !@backtrace.empty?
          fields << {
            name: 'Backtrace',
            value: format_backtrace(@backtrace),
            inline: false
          }
        end

        fields
      end

      def format_backtrace(backtrace)
        return 'No backtrace available' if backtrace.nil? || backtrace.empty?
        
        trace = backtrace.first(@config.backtrace_lines_limit)
        if trace.length >= @config.backtrace_lines_limit
          trace << "... (truncated)"
        end
        trace.join("\n")
      end
    end
  end
end 