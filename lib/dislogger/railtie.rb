# frozen_string_literal: true

module Dislogger
  class Railtie < Rails::Railtie
    initializer 'dislogger.configure_rails_initialization' do
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.include Dislogger::ErrorHandler
      end
    end
  end
end 