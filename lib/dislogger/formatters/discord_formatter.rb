# frozen_string_literal: true

module Dislogger
  module Formatters
    class DiscordFormatter < BaseFormatter
      def format
        {
          username: @config.bot_username,
          embeds: [
            {
              title: "#{@config.environment.capitalize} - Error Notification (#{@status})",
              description: @message,
              color: @config.error_color_map[@status] || @config.error_color_map[:default],
              fields: build_fields,
              timestamp: Time.current.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
            }
          ]
        }
      end

      private

      def build_fields
        fields = [
          { name: 'Status Code', value: @status.to_s, inline: true },
          { name: 'Environment', value: @config.environment, inline: true }
        ]

        if @backtrace
          fields << {
            name: 'Backtrace',
            value: @backtrace.first(@config.backtrace_lines_limit).join("\n"),
            inline: false
          }
        end

        fields
      end
    end
  end
end 