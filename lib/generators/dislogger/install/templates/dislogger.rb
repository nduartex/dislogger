# frozen_string_literal: true

Dislogger.configure do |config|
  # Configura la URL del webhook de Discord (requerido)
  config.discord_webhook_url = ENV['DISCORD_WEBHOOK_URL']

  # Configura el ambiente actual (requerido)
  config.environment = Rails.env

  # Configura el nombre del bot (opcional, por defecto: 'Error Logger')
  # config.bot_username = 'Mi App Error Logger'

  # Configura el número de líneas del backtrace (opcional, por defecto: 5)
  # config.backtrace_lines_limit = 10

  # Configura los ambientes donde las notificaciones están habilitadas
  # (opcional, por defecto: ['production', 'staging', 'development'])
  # config.enabled_environments = ['production', 'staging', 'development']

  # Configura los colores de los errores (opcional)
  # config.error_color_map = {
  #   500 => 15158332, # Rojo para errores del servidor
  #   404 => 3447003,  # Azul para no encontrado
  #   422 => 16776960, # Amarillo para errores de validación
  #   403 => 15105570, # Naranja para prohibido
  #   default: 10181046 # Gris para otros
  # }
end 