# frozen_string_literal: true

module Dislogger
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer_file
        template 'dislogger.rb', 'config/initializers/dislogger.rb'
      end
    end
  end
end 