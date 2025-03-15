# frozen_string_literal: true

require 'rails'

RSpec.describe Dislogger::Railtie do
  describe 'initialization' do
    let(:railtie) { described_class.instance }

    it 'configures the initializer correctly' do
      initializer = railtie.initializers.find { |i| i.name == 'dislogger.configure_rails_initialization' }
      expect(initializer).to be_present
      expect(initializer.name).to eq('dislogger.configure_rails_initialization')
    end

    it 'sets up the ActiveSupport.on_load callback' do
      initializer = railtie.initializers.find { |i| i.name == 'dislogger.configure_rails_initialization' }
      app = double('app')

      expect {
        initializer.run(app)
      }.not_to raise_error
    end
  end
end 