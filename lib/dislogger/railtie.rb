# frozen_string_literal: true

module Dislogger
  class Railtie < Rails::Railtie
    initializer 'dislogger.configure_rails_initialization' do |app|
      # Configurar el ambiente por defecto si no está configurado
      ActiveSupport.on_load(:before_configuration) do
        Dislogger.configure do |config|
          config.environment ||= Rails.env
        end
      end

      # Incluir el ErrorHandler en los controladores
      ActiveSupport.on_load(:action_controller) do
        if defined?(ActionController::API)
          ActionController::API.include(Dislogger::ErrorHandler)
        end
        
        if defined?(ActionController::Base)
          ActionController::Base.include(Dislogger::ErrorHandler)
        end
      end
    end
  end
end 