# frozen_string_literal: true

require "rails"
require "active_support"
require "active_support/concern"
require "active_support/core_ext/string"
require "active_support/core_ext/module/delegation"
require "httparty"
require_relative "dislogger/version"
require_relative "dislogger/configuration"
require_relative "dislogger/error_handler"
require_relative "dislogger/notifiers/base_notifier"
require_relative "dislogger/notifiers/discord_notifier"
require_relative "dislogger/formatters/base_formatter"
require_relative "dislogger/formatters/discord_formatter"
require_relative "dislogger/errors/custom_errors"

module Dislogger
  class Error < StandardError; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset
      @configuration = Configuration.new
    end
  end
end

require "dislogger/railtie" if defined?(Rails)
