# frozen_string_literal: true

module Dislogger
  class Configuration
    attr_accessor :discord_webhook_url,
                 :environment,
                 :bot_username,
                 :error_color_map,
                 :backtrace_lines_limit,
                 :enabled_environments

    def initialize
      @discord_webhook_url = nil
      @bot_username = 'Error Logger'
      @backtrace_lines_limit = 5
      @enabled_environments = ['production', 'staging']
      @environment = defined?(Rails) ? Rails.env : 'development'
      @error_color_map = {
        500 => 15158332, # Red for server errors
        404 => 3447003,  # Blue for not found
        422 => 16776960, # Yellow for validation errors
        403 => 15105570, # Orange for forbidden
        default: 10181046 # Gray for others
      }
    end

    def validate!
      raise Errors::ConfigurationError, 'Discord webhook URL is required' unless discord_webhook_url.present?
      raise Errors::ConfigurationError, 'Bot username is required' unless bot_username.present?
      raise Errors::ConfigurationError, 'Enabled environments must be an array' unless enabled_environments.is_a?(Array)
      raise Errors::ConfigurationError, 'Environment must be present' unless environment.present?
      true
    end

    def enabled?
      return false if environment.nil? || enabled_environments.empty?
      enabled_environments.include?(environment)
    end
  end
end 